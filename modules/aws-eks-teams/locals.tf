locals {
  teams = merge(
      #TODO work on default team example
    # local.default_teams,
    var.teams
  )

}
