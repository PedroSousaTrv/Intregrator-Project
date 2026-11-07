import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Repositório em memória, usado quando não há banco configurado. Os dados se perdem ao fechar. */
public class RepositorioEstudanteMemoria implements RepositorioEstudante {

    private final List<Estudante> estudantes = new ArrayList<>();
    private final Map<String, Integer> instituicoesPorDominio = new HashMap<>();
    private int proximoId = 1;

    public RepositorioEstudanteMemoria() {
        // mesma instituição inserida pelo script do banco
        instituicoesPorDominio.put("unievangelica.edu.br", 1);
    }

    @Override
    public Integer buscarInstituicaoPorDominio(String dominio) {
        return instituicoesPorDominio.get(dominio);
    }

    @Override
    public boolean emailExiste(String emailNormalizado) {
        return buscarPorEmail(emailNormalizado) != null;
    }

    @Override
    public Estudante buscarPorEmail(String emailNormalizado) {
        for (Estudante e : estudantes) {
            if (e.getEmailInstitucional().equals(emailNormalizado)) {
                return e;
            }
        }
        return null;
    }

    @Override
    public boolean adicionar(Estudante estudante) {
        if (emailExiste(estudante.getEmailInstitucional())) {
            return false;
        }
        estudante.setIdEstudante(proximoId++);
        estudantes.add(estudante);
        return true;
    }
}
