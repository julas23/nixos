settings {
  logfile = "/var/log/lsyncd/lsyncd.log";
  statusFile = "/var/log/lsyncd/lsyncd.status";
  maxProcesses = 1;
  insist = true;
  statusInterval = 60;
  nodaemon = false;
  exclude = "/etc/lsyncd/exclude.lst";
}

sync {
  default.rsync,
  source = "/home/juliano/",
  target = "/mnt/nfs/juliano/",
  rsync = {
    _extra = {
      "--files-from=/etc/lsyncd/files.lst",
      "--relative",
      "--no-R",
      "--no-implied-dirs"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.mozilla",
  target = "/mnt/nfs/juliano/.mozilla",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.tor project",
  target = "/mnt/nfs/juliano/.tor project",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.wallpaper",
  target = "/mnt/nfs/juliano/.wallpaper",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.data",
  target = "/mnt/nfs/juliano/.data",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.fonts",
  target = "/mnt/nfs/juliano/.fonts",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.oh-my-zsh",
  target = "/mnt/nfs/juliano/.oh-my-zsh",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.local/share/Steam/steamapps/compatdata",
  target = "/mnt/nfs/juliano/.local/share/Steam/steamapps/compatdata",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.local/share/Steam/userdata",
  target = "/mnt/nfs/juliano/.local/share/Steam/userdata",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/.ssh",
  target = "/mnt/nfs/juliano/.ssh",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Desktop",
  target = "/mnt/nfs/juliano/Desktop",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Documents",
  target = "/mnt/nfs/juliano/Documents",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Downloads",
  target = "/mnt/nfs/juliano/Downloads",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Git",
  target = "/mnt/nfs/juliano/Git",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Music",
  target = "/mnt/nfs/juliano/Music",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Public",
  target = "/mnt/nfs/juliano/Public",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Pictures",
  target = "/mnt/nfs/juliano/Pictures",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Videos",
  target = "/mnt/nfs/juliano/Videos",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}

sync {
  default.rsync,
  source = "/home/juliano/Templates",
  target = "/mnt/nfs/juliano/Templates",
  rsync = {
    archive = true,
    compress = false,
    update = true,
    verbose = true,
    bwlimit = 10000,
    whole_file = false,
    _extra = {
      "--partial", "--inplace",
      "--no-perms", "--no-group",
      "--delete",
      "--chmod=D755,F644"
    }
  }
}
