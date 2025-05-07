# $NetBSD: Makefile,v 1.6 2025/02/02 20:31:27 schmonz Exp $

DISTNAME=	nbpkg-moretools-0.0.20250507
CATEGORIES=	meta-pkgs
MASTER_SITES=	# empty
DISTFILES=	# empty

MAINTAINER=	schmonz@NetBSD.org
COMMENT=	More pkgsrc tools Amitai likes to have

DEPENDS+=	highlight-[0-9]*:../../textproc/highlight # gcc6 or higher
DEPENDS+=	tmux-[0-9]*:../../misc/tmux
DEPENDS+=	cvs-for-gits-[0-9]*:../../devel/cvs-for-gits
DEPENDS+=	p5-Text-Autoformat-[0-9]*:../../textproc/p5-Text-Autoformat
DEPENDS+=	p5-Text-Reform-[0-9]*:../../textproc/p5-Text-Reform
DEPENDS+=	the_silver_searcher-[0-9]*:../../textproc/the_silver_searcher
DEPENDS+=	myrepos-[0-9]*:../../devel/myrepos
DEPENDS+=	cvs-[0-9]*:../../devel/scmcvs
DEPENDS+=	git-base-[0-9]*:../../devel/git-base
DEPENDS+=	mercurial-[0-9]*:../../devel/mercurial
DEPENDS+=	djbdns-[0-9]*:../../net/djbdns
DEPENDS+=	rsync-[0-9]*:../../net/rsync
DEPENDS+=	vim-[0-9]*:../../editors/vim
DEPENDS+=	watch-[0-9]*:../../misc/watch
DEPENDS+=	oksh-[0-9]*:../../shells/oksh
DEPENDS+=	mksh-[0-9]*:../../shells/mksh
DEPENDS+=	links-[0-9]*:../../www/links

META_PACKAGE=	yes

.include "../../mk/bsd.pkg.mk"
