from environment import set_aws_credentials, load_environment_variables


load_environment_variables()
set_aws_credentials()


if __name__ == "__main__":
    from flink_app import main

    main()
