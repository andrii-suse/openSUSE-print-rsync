SBIN_DIR ?= /usr/sbin
USR_DIR ?= /usr
OR_SRV_USER ?= mirror
OR_SRV_GROUP ?= mirror

test_systemd:
	( cd t/systemd; for f in *.sh; do ./$$f && continue; echo FAIL $$f; exit 1 ; done )

install:
	install -d "${DESTDIR}"/usr/bin/ ;\
	for i in *.sh; do \
		ii=$$(basename $$i .sh) ; \
		test $${i} != opensuse-rsync-common.sh || continue ; \
		echo II=$${ii} ; \
		install $$i "${DESTDIR}"/usr/bin/$${ii} ;\
	done
	install opensuse-rsync-common.sh "${DESTDIR}"/usr/bin/ ;\
	install -d -m 755 "${DESTDIR}"/usr/lib/systemd/system
	for i in systemd/*.service; do \
		install -m 644 $$i "${DESTDIR}"/usr/lib/systemd/system ;\
	done; \
	for i in systemd/*.timer; do \
		install -m 644 $$i "${DESTDIR}"/usr/lib/systemd/system ;\
	done

setup_system_user:
	getent group ${OR_SRV_GROUP} > /dev/null || groupadd ${OR_SRV_GROUP}
	getent passwd ${OR_SRV_USER} > /dev/null || ${SBIN_DIR}/useradd -r -g ${OR_SRV_GROUP} -c "openSUSE rsync user" \
	       -d ${USR_DIR}/lib/ ${OR_SRV_USER} 2>/dev/null || :
