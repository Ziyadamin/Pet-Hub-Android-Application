import 'User.dart';

class Pet {
  String name;
  String breed;
  int age;
  String sex;
  User owner;
  List<String> medications;
  List<String> vaccinations;
  String description;

  Pet()
      : name = '',
        breed = '',
        age = 0,
        sex = '',
        owner = RegularUser.defaultConstructor(),
        medications = [],
        vaccinations = [],
        description = '';

  Pet.withDetails(
      this.name,
      this.breed,
      this.age,
      this.sex,
      this.owner,
      this.medications,
      this.vaccinations,
      this.description);

  @override
  String toString() {
    return 'Pet{name: $name, breed: $breed, age: $age, sex: $sex, owner: $owner, medications: $medications, vaccinations: $vaccinations, description: $description}';
  }
}
