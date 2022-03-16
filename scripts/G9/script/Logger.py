import logging

def log_write(file, format, text, level):
    infoLog = logging.FileHandler(file)
    infoLog.setFormatter(format)
    logger = logging.getLogger(file)
    logger.setLevel(level)
    
    if not logger.handlers:
        logger.addHandler(infoLog)
        if (level == logging.INFO):
            logger.info(text)
        if (level == logging.ERROR):
            logger.error(text)
        if (level == logging.WARNING):
            logger.warning(text)
        if (level == logging.CRITICAL):
            logger.critical(text)
        if (level == logging.DEBUG):
            logger.debug(text)
    
    infoLog.close()
    logger.removeHandler(infoLog)
    
    return

formatLog = logging.Formatter('%(asctime)s [%(process)d] %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
#log_write("file.log", formatLog, "New log", logging.INFO)
