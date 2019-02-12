module IdRandomizer
  class Generator
    attr_reader :record, :scope, :column

    def initialize(record, options = {})
      @record = record
      @scope = options[:scope]
      @column = options[:column].to_sym
    end

    def set
      return if id_set?
      lock_table
      record.send(:"#{column}=", generate_id)
    end

    def id_set?
      !record.send(column).nil?
    end

    def generate_id
      id=nil
      loop do
        id = (SecureRandom.random_number(9e6) + 1e6).to_i
        break if unique?(id)
      end
      id
    end

    def unique?(id)
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where("NOT id = ?", record.id) if record.persisted?
        rel.where(column => id)
      end.count == 0
    end

  private

    def lock_table
      if postgresql?
        record.class.connection.execute("LOCK TABLE #{record.class.table_name} IN EXCLUSIVE MODE")
      end
    end

    def postgresql?
      defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
        record.class.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    end

    def base_relation
      record.class.base_class.unscoped
    end

    def build_scope(*columns)
      rel = yield
      columns.each { |c| rel = rel.where(c => record.send(c.to_sym)) }
      rel
    end

  end
end
