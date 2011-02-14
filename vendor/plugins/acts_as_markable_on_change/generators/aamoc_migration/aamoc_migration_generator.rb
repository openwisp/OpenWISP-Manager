class AamocMigrationGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args << 'create_marks'
    super
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', "db/migrate", {:migration_file_name => "create_marks"}
    end
  end
end
