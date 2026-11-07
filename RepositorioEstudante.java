import java.util.ArrayList;
import java.util.List;

public class RepositorioEstudante {
    private List<Estudante> estudantes = new ArrayList<>();

    public Estudante buscarPorEmail(String email) {
        for (Estudante estudante : estudantes) {
            if (estudante.getEmailInstitucional().equals(email)) {
                return estudante;
            }
        }

        System.out.println("Cadastro nao encontrado, confira o e-mail digitado.");
        return null;
    }

    public boolean emailExiste(String email) {

        for (Estudante estudante : estudantes) {
            if (estudante.getEmailInstitucional().equals(email)) {
                return true;
            }
        }
        return false;
    }

    public boolean adicionar(Estudante estudante) {
        if (emailExiste(estudante.getEmailInstitucional())) {
            return false;
        }
        estudantes.add(estudante);
        return true;
    }
}
