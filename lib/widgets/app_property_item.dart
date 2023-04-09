import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../configs/application.dart';
import '../models/model_picker.dart';
import '../models/model_property.dart';
import '../utils/translate.dart';
import '../utils/validate.dart';
import 'app_bottom_picker.dart';
import 'app_picker_item.dart';
import 'app_text_input.dart';

class AppPropertyItem extends StatelessWidget {
  final BuildContext context;
  final PropertyModel property;
  late Widget? wedgit;
  late Object? value = "";
  late String? errorWedgit;
  // final VoidCallback onPressed;
  final void Function(VoidCallback) onPressed;

  AppPropertyItem(
      {required this.context,
      required this.property,
      this.wedgit,
      this.errorWedgit = "",
      required this.onPressed});

  Widget _buildtextInputProperty({required PropertyModel property}) {
    final controller = TextEditingController();
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "${Translate.of(context).translate(property.name)} (${Application.submitSetting.currencies.singleWhere((cur) => cur.isDefault).code})",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Tooltip(
              triggerMode: TooltipTriggerMode.longPress,
              showDuration: const Duration(seconds: 1),
              message: errorWedgit?.isNotEmpty ?? false
                  ? Translate.of(context).translate(errorWedgit)
                  : (value as String?) != ""
                      ? (value as String?)
                      : Translate.of(context)
                          .translate(property.inputPlacement),
              child: AppTextInput(
                hintText:
                    Translate.of(context).translate(property.inputPlacement),
                errorText: errorWedgit,
                controller: controller,
                textInputAction: TextInputAction.done,
                onChanged: (text) {
                  onPressed(() {
                    value = text;
                    errorWedgit = UtilValidator.validate(
                      text,
                      type: ValidateType.realNumber,
                      max: property.max,
                      min: property.min,
                      allowEmpty: false,
                    );
                  });
                },
                trailing: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTap: () {
                    controller.clear();
                  },
                  child: const Icon(Icons.clear),
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  Widget _builditemPickerProperty({required PropertyModel property}) {
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate(property.name),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              leading: Icon(
                Icons.bedroom_parent_outlined,
                color: Theme.of(context).hintColor,
              ),
              value: value as String?,
              title: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? errorWedgit!
                  : Translate.of(context).translate(property.inputPlacement),
              color: errorWedgit != null && errorWedgit!.isNotEmpty
                  ? Theme.of(context).errorColor
                  : null,
              onPressed: () async {
                await _onSelectPropertyItems(property: property);
              },
            ),
          ],
        ),
      ),
    ]);
  }

  Future<void> _onSelectPropertyItems({required PropertyModel property}) async {
    List<String> list = property.textHelper?.split(',').toList() ?? [];

    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => AppBottomPicker(
        picker: PickerModel(
          selected: [(value as String?)],
          data: list,
        ),
        hasScroll: true,
      ),
    );

    if (result != null) {
      onPressed(() {
        value = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    wedgit = Container();
    if (property.fieldType == FieldType.textInput) {
      wedgit = _buildtextInputProperty(property: property);
    } else if (property.fieldType == FieldType.itemPicker) {
      wedgit = _builditemPickerProperty(property: property);
    }

    return wedgit!;
  }
}
