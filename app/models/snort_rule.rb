class SnortRule
  # see: http://oreilly.com/pub/h/1393
  # action proto src_ip src_port direction dst_ip dst_port (options)
  attr_accessor :action, :proto, :src, :sport, :dir, :dst, :dport, :opts

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.action_selections
    actions = []
    actions << Selection.new({id: 'alert',    name: 'alert'})
    actions << Selection.new({id: 'log',      name: 'log'})
    actions << Selection.new({id: 'pass',     name: 'pass'})
    actions << Selection.new({id: 'activate', name: 'activate'})
    actions << Selection.new({id: 'dynamic',  name: 'dynamic'})
    actions << Selection.new({id: 'drop',     name: 'drop'})
    actions << Selection.new({id: 'reject',   name: 'reject'})
    actions << Selection.new({id: 'sdrop',    name: 'sdrop'})
    actions
  end
end
