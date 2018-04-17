# This class allows its subclasses to dynamically create methods
# and instance variables for easier CSV report creation 

class Generic
	def _singleton_class
		class << self
			self
		end
	end

	def method_missing(name,*args,&block)
		if name[-1] == '='
			variable_name = name[0..-2].to_sym
			_singleton_class.instance_exec(name) do |name|	
				define_method(name) do |val|
					instance_variable_set("@#{variable_name}",val)
				end
			end
			instance_variable_set("@#{variable_name}",args.first)
		else
			variable_name = name.to_sym
			_singleton_class.instance_exec(name) do |name|
				define_method(name) do
					instance_variable_get("@#{variable_name}")
				end
			end
			instance_variable_get("@#{variable_name}")
		end
	end
end
