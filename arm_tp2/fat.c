#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include "fat.h"
#include <diskio.h>
#include <termio.h>
#include <vfs.h>

#define READ8(buf,pos)  (buf[(pos)])
#define READ16(buf,pos) (buf[(pos)] | (buf[(pos+1)]<<8))
#define READ32(buf,pos) (buf[(pos)] | (buf[(pos+1)]<<8) | (buf[(pos+2)]<<16) | (buf[(pos+3)]<<24))


static BYTE buf[512];


int fat_mount(FatFS *fat, int partition)
{
	uint8 res, b;
	int32 p2;
	
	// disk initialize
	res = disk_initialize();
	if (res) { term_printf("\nDisk initialization [FATAL] error rc=%d\n", (uint32)res); return -1; }

	if (disk_ioctl(GET_SECTOR_COUNT, &p2) == RES_OK) {
		term_printf("\nDrive size : %u sectors\n", p2);
	}
	if (disk_ioctl(GET_BLOCK_SIZE, &p2) == RES_OK) {
		term_printf("Block size : %u sectors\n", p2);
	}
	if (disk_ioctl(MMC_GET_TYPE, &b) == RES_OK) {
		term_printf("Media type : %u ", b);
		if (b==1) term_printf("(MMC)\n");
		else if (b==2) term_printf("(SDCARD v1)\n");
		else if (b==4) term_printf("(SDCARD v2)\n");
		else term_printf("(Unknown)\n");
	}
	
	// read MBR
	res = disk_read(buf, 0, 1);
	if (res) { term_printf("\nMBR read [FATAL] error rc=%d\n", (uint32)res); return -1; }
	// read partition start sector
	fat->part_start=READ32(buf, 0x1BE + 8);					// !!!! A MODIFIER !!!!
	fat->part_size=READ32(buf, 0x1BE + 12);					// !!!! A MODIFIER !!!!
	
	if (!fat->part_start || !fat->part_size) return -1;
	
	// get Fat filesystem header
	res = disk_read(buf, fat->part_start, 1);
	if (res) { term_printf("\nrc=%d\n", (uint32)res); return -1; }
	
	// check for FAT signature
	if(((READ8(buf,0)!=0xEB)&&(READ8(buf,0)!=0xE9))||
		(READ8(buf,510)!=0x55)||(READ8(buf,511)!=0xAA)) { 
        term_printf("\nBad fat signature !!\n"); 
        return -1; 
	}

	// cluster size (nb of sectors per cluster) : offet 13, 1 byte
	fat->csize = READ8(buf,13);						// !!!! A MODIFIER !!!!

	// header size (in number of sectors) : offset 14, 2 bytes
	uint32 headersize = READ16(buf,14);				// !!!! A MODIFIER !!!!

	fat->fat_start = fat->part_start+headersize;					// !!!! A MODIFIER !!!!

	// File Allocation Table size (in number of sectors) : offset 36, 4 bytes
	fat->fat_size = READ32(buf,36);					// !!!! A MODIFIER !!!!

	// first data sector.
	// number of FATs : offset 16, 1 byte
	fat->data_start = fat->fat_start+READ8(buf,16)*fat->fat_size;				// !!!! A MODIFIER !!!!

	// root dir cluster nb : offset 44, 4 bytes
	fat->root = READ32(buf,44);						// !!!! A MODIFIER !!!!

	return 0;
}

// -------------------- next_cluster ------------------------------------------
// next_cluster : get the next data cluster index from FAT
uint32 next_cluster(FatFS *fat, uint32 cluster)
{
	DRESULT res = disk_read(buf,fat->fat_start+(cluster /128),1);
	if(res)
	{
		term_printf("\n MBR read [FATAL] error rc=%d\n",(uint32)res);
		return -1;
	}
	return READ32(buf,(cluster %128)*4);
}

// -------------------- cluster2sector ------------------------------------------
// cluster2sector : get the first sector in a cluster (fat->csize sectors per cluster)
uint32 cluster2sector(FatFS *fat, uint32 cluster)
{
	return fat->fat_start + (cluster - 2)*fat->csize;
}

// -------------------- cpy_name ------------------------------------------
// cpy_name : convert a src name from the 8.3 format (8 chars + 3 extension 
// chars) to dest standard C string
static void cpy_name(char *dest, char *src){
	char *p=dest, *q;
	for(q=src; q<src+8; q++) {
		if(*q!=' ') {
			*p = *q ;
			if(*p>='A' && *p<='Z') *p += ('a'-'A') ;
			p++;
		}
	}
	if(src[8]!=' ') *(p++) = '.' ;
	for(q=src+8; q<src+11; q++) {
		if(*q!=' ') {
			*p = *q ;
			if(*p>='A' && *p<='Z') *p += ('a'-'A') ;
			p++;
		}
	}
	*p=0 ;
}

// -------------------- fat_get_info -----------------------------
uint32 fat_get_info(FatFS *fat, char *filename, uint32 *size, uint32 *isdir)
{
	// A COMPLETER
	
	int cluster=0, parent_cluster = 0;
	if (strcmp(filename, "/") == 0)
	{
		*isdir = 1;
		*size = 0;
		return fat->root;
	}
	// else, ask to your father

	char *parent_name = dirname(filename);

	parent_cluster = fat_get_info(fat, parent_name, size, isdir);
	free(parent_name);

	if (parent_cluster == 0)
		return 0;

	//parent_sector = cluster2sector(fat, parent_cluster);
	
	// We have found the parent cluster number. Look for the son named 'file'
	char *file = basename(filename);

	do {
		// for each sector in the cluster
			
			// read a sector in the cluster
			
			// for each 32 byte data block (directory entry)
			

		// if the file wasn't found in this cluster, get the next one
		parent_cluster = next_cluster(fat, parent_cluster);
	} while(parent_cluster < 0xffffff8);
	return 0;
}



// -------------------- fat_next_dir -----------------------------
uint32 fat_next_dir(FatFS *fat, DIR *dir)
{
	uint32 sector=cluster2sector(fat, dir->cluster);
	
	uint8 res = disk_read(buf, sector+dir->sindex, 1);
	if (res) { term_printf("\nSector read error (fat_next_dir) rc=%d\n", (uint32)res); return 0; }
	
	// skip false entries
	while ((READ8(buf,dir->offset)==0xE5) || (READ8(buf,dir->offset+11)&0x08)) {
		dir->offset+=32;
		if (dir->offset==512) {						// change sector
			dir->sindex++;
			dir->offset=0;
			if (dir->sindex == fat->csize) {		// change cluster
				dir->sindex=0;
				dir->cluster=next_cluster(fat, dir->cluster);
			}
		}
	}

	// end if first byte is 0
	if(!READ8(buf,dir->offset)) return 0;
	
	// get name, size and isdir
	
	
	// !!!! A COMPLETER !!!!
	
	
	dir->offset+=32;
	if (dir->offset==512) {							// change sector
		dir->sindex++;
		dir->offset=0;
		if (dir->sindex == fat->csize) {			// change cluster
			dir->sindex=0;
			dir->cluster=next_cluster(fat, dir->cluster);
		}
	}

	return 1;
}

// -------------------- fat_read -----------------------------
#define MIN(a,b) ((a)<(b)? (a) : (b))
#define MAX(a,b) ((a)>(b)? (a) : (b))

uint32 fat_read(FatFS *fat, uint32 cluster, uint32 offset, uint32 len, void* buffer)
{
	int nb_read=0;
	uint32 cl=cluster;
	// get the right cluster
	while(offset >= fat->csize*512) {
		cl = next_cluster(fat, cl);
		offset -=fat->csize*512;
	}
	
	while (len) {


		// !!!! A COMPLETER !!!!


		if (len) {		// get the next cluster
			cl = next_cluster(fat, cl);
		}
	}
	return nb_read;
}

/***************************************************************************
 * File device
 ***************************************************************************/
static int dev_fs_init(Device *dev);
static int dev_fs_open(FileObject *f);
static int dev_fs_close(FileObject *f);
static int dev_fs_read(FileObject *f, void *buf, size_t len);

Device dev_fs={
    .name="dev_fs",
    .refcnt=0,
    .sem_read=NULL,
    .sem_write=NULL,
    .init=dev_fs_init,
    .open=dev_fs_open,
    .close=dev_fs_close,
    .read=dev_fs_read,
    .write=NULL,
    .ioctl=NULL
};

FatFS fs;

static int dev_fs_init(Device *dev)
{
	int res = fat_mount(&fs, 0);
	term_printf("\ncluster size      = %u\n", fs.csize);
	term_printf("part start sector = %u\n", fs.part_start);
	term_printf("fat size          = %u\n", fs.fat_size);
	term_printf("data start sector = %u\n", fs.data_start);
	return res;
}

static int dev_fs_open(FileObject *f)
{
	uint32 cluster, size, isdir;
	
    if (f->flags & (O_READ|O_WRITE)) {
        f->dev->refcnt++;
    }
    
    
	// !!!! A COMPLETER !!!!
	
	
    return 0;
}

static int dev_fs_close(FileObject *f)
{


	// !!!! A COMPLETER !!!!

	
    f->dev->refcnt--;
    return 1;
}

static int dev_fs_read(FileObject *f, void *buf, size_t len)
{
	if (f->flags & (F_IS_FILE | O_READ)) {
		FIL *file=f->file;
		int n;


		// !!!! A COMPLETER !!!!


		return n;
	}
	return -1;
}

int dev_fs_next_dir(DIR *dir)
{
	return fat_next_dir(&fs, dir);
}
