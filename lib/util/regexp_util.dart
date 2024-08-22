bool isValidIPv4(String ip, [bool isEqual = false]) {
  String regexp =
      r'((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)';

  final RegExp ipv4RegExp = RegExp(isEqual ? '^$regexp\$' : regexp);
  return ipv4RegExp.hasMatch(ip);
}

bool isValidIPv6(String ip, [bool isEqual = false]) {
  String regexp = r'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,7}:|'
      r'([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|'
      r'([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|'
      r'([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|'
      r'([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|'
      r'[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|'
      r':((:[0-9a-fA-F]{1,4}){1,7}|:)|'
      r'fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|'
      r'::ffff:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|'
      r'(?:[0-9a-fA-F]{1,4}:){1,4}:((?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)))';

  final RegExp ipv6RegExp = RegExp(isEqual ? '^$regexp\$' : regexp);
  return ipv6RegExp.hasMatch(ip);
}

bool isValidDomain(String domain) {
  final RegExp domainRegExp = RegExp(
    r'^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.?$',
  );

  return domainRegExp.hasMatch(domain);
}