public class Fib {
  public static void main(String[] args) {
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
    System.out.println(fib(Long.valueOf(40)));
  }

  public static Long fib(Long a) {
    if (lt(a, Long.valueOf(2))) {
      return a;
    } else {
      return plus(fib(minus(a, Long.valueOf(1))), fib(minus(a, Long.valueOf(2))));
    }
  }

  public static Long plus(Long a, Long b) {
    return a + b;
  }

  public static Long minus(Long a, Long b) {
    return a - b;
  }

  public static Boolean lt(Long a, Long b) {
    return a < b;
  }
}
