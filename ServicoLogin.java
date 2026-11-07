import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Fluxo de login (RF-002) com limite de tentativas (corrige F-09, RNF-017).
 * A mensagem de erro é a mesma para e-mail inexistente e senha errada,
 * para não revelar quais e-mails estão cadastrados.
 */
public class ServicoLogin {

    static final int MAX_TENTATIVAS = 5;
    static final Duration TEMPO_BLOQUEIO = Duration.ofMinutes(5);

    private final RepositorioEstudante rep;
    private final Entrada entrada;
    private final Map<String, Integer> falhas = new HashMap<>();
    private final Map<String, Instant> bloqueadoAte = new HashMap<>();

    public ServicoLogin(RepositorioEstudante rep, Entrada entrada) {
        this.rep = rep;
        this.entrada = entrada;
    }

    public Estudante servicoLogin() {
        System.out.println("========== BEM-VINDO(A) DE VOLTA ==========");
        String email = Validador.normalizarEmail(entrada.lerTexto("E-mail:"));

        Instant ate = bloqueadoAte.get(email);
        if (ate != null && Instant.now().isBefore(ate)) {
            long segundos = Duration.between(Instant.now(), ate).getSeconds();
            long minutos = Math.max(1, (segundos + 59) / 60); // arredonda para cima
            System.out.println("Muitas tentativas sem sucesso. Tente novamente em " + minutos + " minuto(s).");
            return null;
        }

        String senha = entrada.lerTexto("Senha:");
        Estudante estudante = rep.buscarPorEmail(email);

        if (estudante != null && SenhaHash.confere(senha, estudante.getSenhaHash())) {
            falhas.remove(email);
            bloqueadoAte.remove(email);
            System.out.println("Login realizado com sucesso!");
            System.out.println("Ola, " + estudante.getNomeCompleto() + "! Seja bem-vindo ao sistema.");
            return estudante;
        }

        int total = falhas.merge(email, 1, Integer::sum);
        System.out.println("E-mail ou senha incorretos.");
        if (total >= MAX_TENTATIVAS) {
            bloqueadoAte.put(email, Instant.now().plus(TEMPO_BLOQUEIO));
            falhas.remove(email);
            System.out.println("Acesso bloqueado por " + TEMPO_BLOQUEIO.toMinutes() + " minutos apos "
                    + MAX_TENTATIVAS + " tentativas.");
        } else {
            System.out.println("Tentativas restantes: " + (MAX_TENTATIVAS - total) + ".");
        }
        return null;
    }
}
