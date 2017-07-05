require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE students(
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
        )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE students
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id.nil?
      sql = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(student_a)
    Student.new(student_a[1], student_a[2], student_a[0])
  end

  def self.find_by_name(student)
    sql = <<-SQL
        SELECT * FROM students
        WHERE name = (?)
      SQL
    self.new_from_db(DB[:conn].execute(sql, student)[0])
  end

  def update
    sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
