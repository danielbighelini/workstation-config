.DEFAULT_GOAL := help

ANSIBLE_DIR := ansible

.PHONY: \
	help \
	bootstrap \
	provision \
	install \
	lint \
	yaml \
	syntax \
	check \
	clean \
	info \
	doctor

help:
	@echo ""
	@echo "Targets disponíveis:"
	@echo ""
	@echo "  make bootstrap   - Bootstrap inicial da workstation"
	@echo "  make provision   - Executa provisionamento Ansible"
	@echo "  make install     - Instala collections Ansible"
	@echo "  make lint        - Executa ansible-lint"
	@echo "  make yaml        - Executa yamllint"
	@echo "  make syntax      - Executa syntax-check dos playbooks"
	@echo "  make check       - Executa validações completas"
	@echo "  make clean       - Remove artefatos temporários"
	@echo "  make info        - Exibe informações do ambiente"
	@echo "  make doctor      - Valida dependências do ambiente"
	@echo ""

bootstrap:
	./scripts/bootstrap.sh

provision:
	./scripts/provision.sh

install:
	cd $(ANSIBLE_DIR) && \
	ansible-galaxy collection install \
		-r requirements.yml \
		-p collections

lint:
	cd $(ANSIBLE_DIR) && \
	ansible-lint playbooks roles

yaml:
	yamllint ansible

syntax:
	@cd $(ANSIBLE_DIR) && \
	for playbook in playbooks/*.yml; do \
		echo "==> $$playbook"; \
		ansible-playbook $$playbook --syntax-check; \
	done

check:
	@$(MAKE) yaml
	@$(MAKE) lint
	@$(MAKE) syntax

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.retry" -delete

info:
	@echo ""
	@echo "Python:"
	@python3 --version
	@echo ""
	@echo "Ansible:"
	@ansible --version
	@echo ""
	@echo "pipx:"
	@pipx --version

doctor:
	@echo ""
	@echo "Validando ambiente..."
	@echo ""

	@command -v git >/dev/null \
		&& echo "[OK] git" \
		|| (echo "[ERRO] git ausente" && exit 1)

	@command -v python3 >/dev/null \
		&& echo "[OK] python3" \
		|| (echo "[ERRO] python3 ausente" && exit 1)

	@command -v pipx >/dev/null \
		&& echo "[OK] pipx" \
		|| (echo "[ERRO] pipx ausente" && exit 1)

	@command -v ansible >/dev/null \
		&& echo "[OK] ansible" \
		|| (echo "[ERRO] ansible ausente" && exit 1)

	@command -v ansible-lint >/dev/null \
		&& echo "[OK] ansible-lint" \
		|| (echo "[ERRO] ansible-lint ausente" && exit 1)

	@command -v yamllint >/dev/null \
		&& echo "[OK] yamllint" \
		|| (echo "[ERRO] yamllint ausente" && exit 1)

	@command -v docker >/dev/null \
		&& echo "[OK] docker" \
		|| echo "[WARN] docker ausente"

	@command -v pwsh >/dev/null \
		&& echo "[OK] powershell" \
		|| echo "[WARN] powershell ausente"

	@echo ""
	@echo "Ambiente validado."
