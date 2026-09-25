output "ruleset_ids" {
  description = "IDs of the rulesets created by this test."
  value = {
    main_pull_request        = github_repository_ruleset.main_pull_request.ruleset_id
    main_required_check      = github_repository_ruleset.main_required_check.ruleset_id
    release_branch_lifecycle = github_repository_ruleset.release_branch_lifecycle.ruleset_id
  }
}
