package hello

import (
    "testing"
)

func TestHello(t *testing.T) {
  expected := "Hello World"
  result := Hello()

  if result != expected {
    t.Errorf("Hello() = %v; want %v", result, expected)
  }
}

