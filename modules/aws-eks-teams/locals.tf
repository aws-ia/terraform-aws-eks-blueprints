locals {
  teams = merge(
      #TODO work on default team example
    # local.default_teams,
    var.teams
  )
  team_manifests = flatten([
    for team_name, team_data in var.teams :
    fileset(path.root, "${team_data.manifests_dir}/*")
  ])
}
