class Acfa::DigitalObject < Arclight::DigitalObject
  attr_reader :role, :type

  def initialize(label:, href:, **digital_object_attrs)
    super(label: label, href: href)
    @role = digital_object_attrs[:role]
    @type = digital_object_attrs[:type]
  end

  def to_json(*)
    { label: label, href: href, role: role, type: type }.compact.to_json
  end

  def self.from_json(json)
    object_data = JSON.parse(json)
    new(label: object_data['label'], href: object_data['href'], role: object_data['role'], type: object_data['type'])
  end

  def ==(other)
    href == other.href && label == other.label && role == other.role && type == other.type 
  end
end