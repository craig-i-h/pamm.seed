package org.pamm.domain.project.service;

import com.fasterxml.jackson.databind.JsonNode;
import io.jsonwebtoken.Claims;
import org.pamm.dal.project.ProjectRepository;
import org.pamm.domain.ServiceResult;
import org.pamm.domain.project.model.Project;
import org.pamm.domain.project.model.ProjectMember;
import org.pamm.infrastructure.mail.EmailService;
import org.pamm.infrastructure.security.authentication.Principal;
import play.Logger;
import play.libs.Json;
import play.mvc.Http;

import javax.inject.Inject;

public class CreateProjectOperation {
    private static final Logger.ALogger LOG = Logger.of(CreateProjectOperation.class);

    private final ProjectRepository projectRepository;
    private final EmailService emailService;

    @Inject
    public CreateProjectOperation(ProjectRepository projectRepository,
                                  EmailService emailService) {
        this.projectRepository = projectRepository;
        this.emailService = emailService;
    }

    public ServiceResult execute(final JsonNode jsonRequest) {
        final Principal principal = (Principal) Http.Context.current().args.get(Principal.class.getName());
        final Project project = Json.fromJson(jsonRequest, Project.class);

        final Claims claims = principal.getClaims();
        final ProjectMember ownerMember = new ProjectMember();

        ownerMember.setUserId(new Integer((String) claims.get("id")));
        ownerMember.setForename((String) claims.get("forename"));
        ownerMember.setSurname((String) claims.get("surname"));
        ownerMember.setEmail((String) claims.get("email"));
        ownerMember.setRole(ProjectMember.Role.OWNER);

        project.setOwner(ownerMember);

        final Project savedProject = projectRepository.set(project);

        // TODO email project members

        return new ServiceResult(Json.toJson(savedProject));
    }
}
