import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tagContainer", "select"]

  addSkill(event) {
    const skill = event.target.value
    if (!skill) return

    const badge = document.createElement("span")
    badge.classList.add("badge", "badge-primary", "gap-1")
    badge.dataset.skillsInputTarget = "tag"
    badge.innerHTML = `
      ${skill}
      <button type="button" data-action="skills-input#removeSkill" data-skill="${skill}" class="btn btn-ghost btn-xs">&times;</button>
      <input type="hidden" name="user[skills][]" value="${skill}">
    `
    this.tagContainerTarget.appendChild(badge)

    const option = event.target.querySelector(`option[value="${skill}"]`)
    if (option) option.disabled = true

    event.target.value = ""
  }

  removeSkill(event) {
    const skill = event.currentTarget.dataset.skill
    const badge = event.currentTarget.closest("[data-skills-input-target='tag']")
    if (badge) badge.remove()

    const option = this.selectTarget.querySelector(`option[value="${skill}"]`)
    if (option) option.disabled = false
  }
}
