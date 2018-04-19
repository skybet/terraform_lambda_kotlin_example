terragrunt = {
  terraform {
    extra_arguments "force_apply" {
      commands = [
        "apply",
      ]

      arguments = [
        "--auto-approve"
      ]
    }
    extra_arguments "force_destroy" {
      commands = [
        "destroy",
      ]

      arguments = [
        "-force"
      ]
    }

    before_hook "build_kotlin_jar" {
      commands = ["apply"]
      execute = ["../kotlin/local_gradlew.sh", "shadowjar"]
      # execute = ["pwd"]
      run_on_error = false
    }
  }
}

