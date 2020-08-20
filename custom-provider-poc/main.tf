data "cheesecake_cheesecakes" "all" {}

output "cheesecakes" {
  value = data.cheesecake_cheesecakes.all.cheesecakes
}
