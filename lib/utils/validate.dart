enum ValidateType { normal, email, number, realNumber, phone, tag, url }

class UtilValidator {
  static const String errorEmpty = "value_not_empty";
  static const String errorRange = "value_not_valid_range";
  static const String errorUrl = "value_not_valid_url";
  static const String errorEmail = "value_not_valid_email";
  static const String errorNumber = "value_not_number";
  static const String errorRealNumber = "value_not_real_number";
  static const String errorPhone = "value_not_phone";
  static const String errorPassword = "value_not_valid_password";
  static const String errorId = "value_not_valid_id";
  static const String moreThanMax = "maximum_number_of_characters";
  static const String moreThanMin = "minimum_number_of_characters";
  static const String valueNotMatch = "value_not_match";
  static const String valueNotIsTag = "value_not_is_tag";

  static String? validate(
    String data, {
    ValidateType? type = ValidateType.normal,
    double? min,
    double? max,
    bool allowEmpty = false,
    String? match,
  }) {
    ///Empty
    if (!allowEmpty && data.isEmpty) {
      return errorEmpty;
    }

    ///Match
    if (match != null && match != data) {
      return valueNotMatch;
    }

    ///Max
    if (max != null && data.isNotEmpty) {
      if ((type == ValidateType.number || type == ValidateType.realNumber)) {
        if (double.tryParse(data)! > max) {
          return "$moreThanMax (${max.toInt()})";
        }
      } else if (data.length > max) {
        return "$moreThanMax (${max.toInt()})";
      }
    }

    ///Min
    if (min != null && data.isNotEmpty) {
      if ((type == ValidateType.number || type == ValidateType.realNumber)) {
        if (double.tryParse(data)! < min) {
          return "$moreThanMin (${min.toInt()})";
        }
      } else if (data.length < min) {
        return "$moreThanMin (${min.toInt()})";
      }
    }

    if (data.isEmpty) return null;

    switch (type) {

      ///Url pattern
      case ValidateType.url:
        final urlRegex = RegExp(
          r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        );
        if (!urlRegex.hasMatch(data)) {
          return errorUrl;
        }
        break;

      ///Email pattern
      case ValidateType.email:
        final emailRegex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
        );
        if (!emailRegex.hasMatch(data)) {
          return errorEmail;
        }
        break;

      ///Phone pattern
      case ValidateType.phone:
        final phoneRegex = RegExp(r'^[0-9]*$');
        if (!phoneRegex.hasMatch(data)) {
          return errorNumber;
        }
        break;

      ///Phone pattern
      case ValidateType.realNumber:
        const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
        final realNumberRegex = RegExp(pattern);
        if (!realNumberRegex.hasMatch(data)) {
          return errorRealNumber;
        }
        break;

      ///Phone pattern
      case ValidateType.number:
        const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
        final phoneRegex = RegExp(pattern);
        if (!phoneRegex.hasMatch(data)) {
          return errorPhone;
        }
        break;

      ///Tag pattern
      case ValidateType.tag:
        final tagRegex = RegExp(r'^([^0-9|\,\s]*)$');
        if (!tagRegex.hasMatch(data)) {
          return valueNotIsTag;
        }
        break;
      default:
    }
    return null;
  }

  ///Singleton factory
  static final UtilValidator _instance = UtilValidator._internal();

  factory UtilValidator() {
    return _instance;
  }

  UtilValidator._internal();
}
