class SplitAgreementPdfGenerator
  include Prawn::View

  def initialize(agreement)
    @agreement = agreement
    @project = agreement.project
    @entries = agreement.split_entries.includes(:user).order(percentage: :desc)
  end

  def generate
    document.render
  end

  private

  def document
    @document ||= Prawn::Document.new(page_size: "A4", margin: 50).tap do |pdf|
      @pdf = pdf
      render_header
      render_project_details
      render_split_table
      render_approval_details
      render_agreement_info
      render_footer
    end
  end

  def render_header
    @pdf.text "SPLIT AGREEMENT", size: 24, style: :bold, align: :center
    @pdf.text "Revenue Distribution Agreement", size: 12, align: :center, color: "666666"
    @pdf.move_down 5
    @pdf.text "SplitFlow", size: 10, align: :center, color: "999999"
    @pdf.move_down 20
    @pdf.stroke_horizontal_rule
    @pdf.move_down 20
  end

  def render_project_details
    @pdf.text "Project Details", size: 16, style: :bold
    @pdf.move_down 10

    details = [
      ["Project Title", @project.title],
      ["Owner", owner_name],
      ["Genre", @project.genre.presence || "Not specified"],
      ["BPM", @project.bpm.present? ? @project.bpm.to_s : "Not specified"],
      ["Participants", @entries.count.to_s]
    ]

    @pdf.table(details, width: @pdf.bounds.width) do |t|
      t.cells.borders = [:bottom]
      t.cells.border_color = "DDDDDD"
      t.cells.padding = [8, 10]
      t.column(0).font_style = :bold
      t.column(0).width = 150
    end

    if @project.description.present?
      @pdf.move_down 10
      @pdf.text "Description", size: 11, style: :bold, color: "666666"
      @pdf.move_down 4
      @pdf.text @project.description, size: 10, color: "333333"
    end

    @pdf.move_down 20
  end

  def render_split_table
    @pdf.text "Split Distribution", size: 16, style: :bold
    @pdf.move_down 10

    header = ["Participant", "Email", "Role", "Percentage"]
    rows = @entries.map do |entry|
      collaboration = @project.collaborations.accepted.find_by(user: entry.user)
      role = entry.user == @project.owner ? "Owner" : (collaboration&.role.presence || "Collaborator")

      [
        entry.user.display_name || entry.user.email.split("@").first,
        entry.user.email,
        role,
        "#{entry.percentage.to_f.round(2)}%"
      ]
    end

    rows << [{ content: "Total", colspan: 3, font_style: :bold }, { content: "#{@agreement.total_percentage.to_f.round(2)}%", font_style: :bold }]

    @pdf.table([header] + rows, width: @pdf.bounds.width, header: true) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "333333"
      t.row(0).text_color = "FFFFFF"
      t.cells.padding = [8, 10]
      t.cells.borders = [:bottom]
      t.cells.border_color = "DDDDDD"
      t.row(-1).borders = [:top]
      t.row(-1).border_color = "333333"
      t.row(-1).border_width = 2
      t.column(3).align = :right
    end

    @pdf.move_down 20
  end

  def render_approval_details
    @pdf.text "Approval Record", size: 16, style: :bold
    @pdf.move_down 10

    header = ["Participant", "Status", "Approved At"]
    rows = @entries.map do |entry|
      [
        entry.user.display_name || entry.user.email.split("@").first,
        entry.approved? ? "Approved" : "Pending",
        entry.approved? ? entry.approved_at.strftime("%B %d, %Y at %I:%M %p UTC") : "—"
      ]
    end

    @pdf.table([header] + rows, width: @pdf.bounds.width, header: true) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = "333333"
      t.row(0).text_color = "FFFFFF"
      t.cells.padding = [8, 10]
      t.cells.borders = [:bottom]
      t.cells.border_color = "DDDDDD"
    end

    @pdf.move_down 20
  end

  def render_agreement_info
    @pdf.stroke_horizontal_rule
    @pdf.move_down 15

    @pdf.text "Agreement Status", size: 16, style: :bold
    @pdf.move_down 10

    info = [
      ["Status", @agreement.locked? ? "Locked & Immutable" : @agreement.status.capitalize],
      ["Locked At", @agreement.locked_at&.strftime("%B %d, %Y at %I:%M %p UTC") || "—"],
      ["Created At", @agreement.created_at.strftime("%B %d, %Y at %I:%M %p UTC")],
      ["Verification Token", @agreement.verification_token]
    ]

    @pdf.table(info, width: @pdf.bounds.width) do |t|
      t.cells.borders = [:bottom]
      t.cells.border_color = "DDDDDD"
      t.cells.padding = [8, 10]
      t.column(0).font_style = :bold
      t.column(0).width = 150
    end

    @pdf.move_down 20
  end

  def render_footer
    @pdf.stroke_horizontal_rule
    @pdf.move_down 10

    verification_url = Rails.application.routes.url_helpers.verify_split_agreement_url(
      @agreement.verification_token,
      host: default_host
    )

    @pdf.text "Public Verification", size: 11, style: :bold, color: "666666"
    @pdf.move_down 4
    @pdf.text "This agreement can be independently verified at:", size: 9, color: "666666"
    @pdf.text verification_url, size: 9, color: "0066CC"
    @pdf.move_down 10

    @pdf.text "Generated by SplitFlow on #{Time.current.strftime('%B %d, %Y at %I:%M %p UTC')}",
      size: 8, color: "999999", align: :center

    @pdf.text "This document serves as a record of the agreed revenue split distribution.",
      size: 8, color: "999999", align: :center
  end

  def owner_name
    @project.owner.display_name || @project.owner.email
  end

  def default_host
    Rails.application.config.action_mailer.default_url_options&.fetch(:host, "localhost:3000") || "localhost:3000"
  end
end
