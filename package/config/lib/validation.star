load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_label(value):
  return len(value) <= 63 and regexp.match("^" + _dns_label + "$", value)
end

def is_dns_name(value):
  return regexp.match("^" + _dns_label + "(\\." + _dns_label + ")*$", value)
end

def is_hours(value):
  return regexp.match("^[1-9][0-9]*h$", value)
end

def hours(value):
  return int(value[:-1])
end

def is_email(value):
  return regexp.match("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", value)
end

# A DNS server address in the form `<host>:<port>`, like `ns1.example.com:53` or `10.0.0.53:53`.
def is_host_port(value):
  return regexp.match("^[^:\\s]+:[0-9]{1,5}$", value)
end
