variable "repository_owner" {
  description = "Owner of the ruleset test repository."
  type        = string
  default     = "bahag-banasiks"
}

variable "repository_name" {
  description = "Name of the ruleset test repository."
  type        = string
  default     = "ruleset-test"
}

variable "test_app_id" {
  description = "Numeric GitHub App ID allowed to bypass selected rules."
  type        = number
}
