# Seeds for Ninja CRM
puts "Seeding categories..."
coaching = Category.find_or_create_by!(name: "Coaching")
contracting = Category.find_or_create_by!(name: "Contracting")
recruiting = Category.find_or_create_by!(name: "Recruiting")

puts "Seeding message templates..."
Template.find_or_create_by!(category: coaching) do |t|
  t.body = <<~TEXT.strip
    Hi {{name}},

    I noticed your team's great work at {{company}}. I specialize in executive and engineering leadership coaching to help leaders unlock their full potential and scale their teams sustainably.

    Would you be open to a brief 15-minute intro chat next Tuesday or Thursday?

    Best regards,
  TEXT
end

Template.find_or_create_by!(category: contracting) do |t|
  t.body = <<~TEXT.strip
    Hi {{name}},

    Hope you're having a productive week! I help companies like {{company}} ship critical software projects and architectural overhauls on tight deadlines.

    If you have any upcoming engineering contracts or specialized project needs, I'd love to see if there's a strong fit.

    Best,
  TEXT
end

Template.find_or_create_by!(category: recruiting) do |t|
  t.body = <<~TEXT.strip
    Hello {{name}},

    I came across your profile and was impressed by your trajectory at {{company}}. We're currently curating senior talent pipelines for high-growth tech companies.

    Are you currently open to hearing about discreet leadership or staff-level opportunities?

    Cheers,
  TEXT
end

puts "Seeding contacts..."
alice = Contact.find_or_create_by!(name: "Alice Walker") do |c|
  c.email = "alice@acme.inc"
  c.phone = "+1 (555) 234-5678"
  c.company = "Acme Corp"
  c.role = "VP of Engineering"
  c.linkedin_url = "https://linkedin.com/in/alicewalker"
  c.notes = "Met at SaaStr conference. Interested in scaling tech leads."
end

bob = Contact.find_or_create_by!(name: "Bob Martinez") do |c|
  c.email = "bob@startupflow.io"
  c.phone = "+1 (555) 345-6789"
  c.company = "StartupFlow"
  c.role = "Founder & CEO"
  c.linkedin_url = "https://linkedin.com/in/bobmartinez"
  c.notes = "Looking for external contracting support for their v2 launch."
end

charlie = Contact.find_or_create_by!(name: "Charlie Zhang") do |c|
  c.email = "charlie@nexusai.com"
  c.phone = "+1 (555) 456-7890"
  c.company = "Nexus AI"
  c.role = "Head of People"
  c.linkedin_url = "https://linkedin.com/in/charliezhang"
  c.notes = "Actively recruiting principal ML engineers."
end

diana = Contact.find_or_create_by!(name: "Diana Prince") do |c|
  c.email = "diana@themyscira.io"
  c.phone = "+1 (555) 987-6543"
  c.company = "Amazonian Tech"
  c.role = "Chief Technology Officer"
  c.linkedin_url = "https://linkedin.com/in/dianaprince"
  c.notes = "Contact without lead yet. Good prospective lead for coaching."
end

puts "Seeding leads..."
Lead.find_or_create_by!(contact: alice) do |l|
  l.category = coaching
  l.status = "in_progress"
  l.notes = "Intro call scheduled for next Thursday at 2pm."
end

Lead.find_or_create_by!(contact: bob) do |l|
  l.category = contracting
  l.status = "backlog"
  l.notes = "Sent initial outreach template. Need to follow up next week."
end

Lead.find_or_create_by!(contact: charlie) do |l|
  l.category = recruiting
  l.status = "done"
  l.notes = "Agreement signed for 2 engineering placements!"
end

puts "Database seeded successfully!"
