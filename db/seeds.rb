# Create a sample project
project = Project.new(name: "Alansar Hospital")
if project.save
  puts "Project created successfully!"
else
  puts "Failed to create project: #{project.errors.full_messages.join(', ')}"
  exit
end

# Create a sample project scope
project_scope = project.project_scopes.new(name: "Electrical")
if project_scope.save
  puts "Project Scope created successfully!"
else
  puts "Failed to create project scope: #{project_scope.errors.full_messages.join(', ')}"
  exit
end

# Create a sample system
system = System.new(
  name: "Low Current",
  project: project,
  project_scope: project_scope
)
if system.save
  puts "System created successfully!"
else
  puts "Failed to create system: #{system.errors.full_messages.join(', ')}"
  exit
end

# Create a sample subsystem
subsystem = system.subsystems.new(name: "Fire Alarm")
if subsystem.save
  puts "Subsystem created successfully!"
else
  puts "Failed to create subsystem: #{subsystem.errors.full_messages.join(', ')}"
  exit
end

puts "Seed data created successfully!"