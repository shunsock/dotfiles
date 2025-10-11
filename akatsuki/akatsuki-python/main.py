class Person:
    def __init__(self, name: str, age: int) -> None:
        self.name = name
        self.age = age


def greet(person: Person) -> None:
    print(f"Hello {person.name}")


if __name__ == "__main__":
    me: Person = Person(
        name="shunsock",
        age=100
    )
    greet(me)
