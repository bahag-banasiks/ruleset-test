resource "github_repository_ruleset" "main_pull_request" {
  name        = "main-pull-request"
  repository  = var.repository_name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = var.test_app_id
    actor_type  = "Integration"
    bypass_mode = "pull_request"
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }
  }
}

resource "github_repository_ruleset" "main_required_check" {
  name        = "main-required-check"
  repository  = var.repository_name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    required_status_checks {
      required_check {
        context = "Ruleset Test CI"
      }

      strict_required_status_checks_policy = false
    }
  }
}

resource "github_repository_ruleset" "release_branch_lifecycle" {
  name        = "release-branch-lifecycle"
  repository  = var.repository_name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/release/PPS_*"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = var.test_app_id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    creation         = true
    deletion         = true
    non_fast_forward = true
  }
}
