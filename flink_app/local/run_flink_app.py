from local.environment import load_environment_variables, set_aws_credentials


load_environment_variables()
set_aws_credentials()


if __name__ == "__main__":
    from main import main

    main()
