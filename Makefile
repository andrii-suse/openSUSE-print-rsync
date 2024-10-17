
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

