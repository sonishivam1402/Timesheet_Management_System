using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace UCITMS.ViewModels
{
    public class VMMenu
    {
        [Key]
        public int ID { get; set; }

        [Required]
        [DisplayName("Menu Name")]
        public string MenuName { get; set; }

        [Required]
        [DisplayName("Image Path")]
        public string ImagePath { get; set; }

        [Required]
        [DisplayName("Navigation Path")]
        public string NavigationPath { get; set; }

        [Required]
        [DisplayName("Navigation Type")]
        public string NavigationType { get; set; }

        [Required]
        [DisplayName("Sort Order")]
        public int SortOrder { get; set; }

        [Required]
        public bool IsActive { get; set; }

        [Required]
        public bool IsDefault { get; set; }

        [Required]
        public int CreatedBy { get; set; }

        [Required]
        public int ModifiedBy { get; set; }
    }
}
