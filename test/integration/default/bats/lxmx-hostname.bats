#!/usr/bin/env bats

@test "hostname set" {
  run hostname
  [ "$output" = "beautybeast" ]
}

@test "FQDN set" {
  run hostname --fqdn
  [ "$output" = "beautybeast.lemuriens.com" ]
}
