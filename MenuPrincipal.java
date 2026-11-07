import java.util.Scanner;

public class MenuPrincipal {
    public int value;

    public void menuPrin() {
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("==========Menu Principal==========");
            System.out.println("[1] Criar conta");
            System.out.println("[2] Já tenho conta");
            value =sc.nextInt();
             if(value != 1 && value != 2){
                 System.out.println("Input invalido! Confira opções validas no menu.");
             } else{
                 break;
             }
        }
    }
}
