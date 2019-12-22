abstract class NamedDto {
  final String name;
  final String description;

  NamedDto(this.name, this.description);
}

class MaterialDto extends NamedDto {
  final String category;

  MaterialDto(String name, String description, this.category) : super(name, description);

  factory MaterialDto.fromJson(Map<String, dynamic> json) {
    return MaterialDto(json['name'], json['description'], json['category']);
  }
}

class MaterialList {
  List<MaterialDto > materialList;

  MaterialList(this.materialList);

  factory MaterialList.fromJson(Map<String, dynamic> json) {
    List<dynamic> listDto = json['materialList'];

    List<MaterialDto> dtos = new List();

    for (int i = 0; i < listDto.length; i++) {
      // TO DO
      Map<String, dynamic> matDto= listDto[i];
      MaterialDto dto = MaterialDto.fromJson(matDto);
      dtos.add(dto);
    }

    return MaterialList(dtos);
  }
}