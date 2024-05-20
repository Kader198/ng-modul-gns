#!/bin/bash

# Check if a module name is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Please provide a module name as an argument."
  exit 1
fi

# Check if attributes are provided as arguments
if [ -z "$2" ]; then
  echo "Error: Please provide attributes as arguments."
  exit 1
fi

# Define the module name (lowercase for consistency)
module_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Split the attributes string into an array
IFS=',' read -r -a attributes <<< "$2"

# Generate the main module using Angular CLI
ng generate module "$module_name"

# Generate the routing module using Angular CLI
ng generate module "$module_name"/"$module_name"-routing --flat --module="$module_name"

# Inform the user that the module and routing module have been created
echo "Module and routing module for '$module_name' have been created."

# Create the required folder structure
mkdir -p "$module_name"/{pages,models,services,ui}

# Create the Angular components inside the pages folder
ng generate component "$module_name"/pages/list-"$module_name" --module="$module_name"/"$module_name".module
ng generate component "$module_name"/pages/add-"$module_name" --module="$module_name"/"$module_name".module
ng generate component "$module_name"/pages/edit-"$module_name" --module="$module_name"/"$module_name".module
ng generate component "$module_name"/pages/delete-"$module_name" --module="$module_name"/"$module_name".module
ng generate component "$module_name"/pages/layout-"$module_name" --module="$module_name"/"$module_name".module

# Create the service inside the services folder
ng generate service "$module_name"/services/"$module_name"

# Create the model file inside the models folder
model_file="$module_name/models/$module_name.model.ts"
touch "$model_file"

# Create the interface in the model file with the required attributes
echo "export interface ${module_name^}Model {" > "$model_file"
# add id attribute to the model
echo "  id?: number;" >> "$model_file"
for attribute in "${attributes[@]}"; do
  echo "  $attribute: string;" >> "$model_file"
done
echo "}" >> "$model_file"

# Inform the user about the folder and file creation
echo "Created folder structure and components for '$module_name'."

# Path to the list component HTML file
list_component_html="$module_name/pages/list-"$module_name"/list-"$module_name".component.html"

# Content to be inserted into the list component HTML file

list_html_content='<app-modal
  [isModalOpen]="openModalAdd'"$module_name"'Model"
  (closeModalEvent)="closeModalAdd'"$module_name"'ModelFn()"
  [title]="'"$module_name"'"
  [backDropNone]="true"
  size="lg"
>
  <app-add-'"$module_name"'
    (close)="closeModalAdd'"$module_name"'ModelFn()"
  ></app-add-'"$module_name"'>
</app-modal>

<div class="gap-4 py-10 px-5 rounded-lg shadow-sm r bg-white">
  <h1 class="f-outfit text-xl">
    Listes des '"$module_name"'s
  </h1>
  <span class="f-outfit text-primary"></span>

  <div class="grid grid-cols-2">
    <div class="col-span-3 text-end text-sm">
      <button
        class="bg-white h-12 center text-center text-black border border-border-button-color px-5 mx-1 rounded f-outfit"
      >
        {{ '\''RESTAURANT.ROLES.EXPORT'\'' | translate }}
        <img
          alt="Export"
          class="w-4 h-4 inline mx-1 mb-1"
          src="../../../../assets/images/download.png"
        />
      </button>
      <button
        (click)="openModalAdd'"$module_name"'ModelFn()"
        class="bg-main-panel center text-center h-12 text-primary px-5 mx-1 rounded f-outfit"
      >
        <img
          alt="add"
          class="w-4 h-4 inline mx-1"
          src="../../../../assets/images/+.png"
        />
        Ajouter un '"$module_name"'
      </button>
    </div>
  </div>

  <!-- plan list -->
  <app-table
    [data$]="'"$module_name"'s$"
    [columns]="tableColumns"
    [showOrder]="false"
    [actions]="actionsBtns"
    [showSearch]="false"
    (actionStatus)="toggleStatus($event)"
    [filter]="{ key: '\''name'\'', value: '\''apple'\'' }"
    [showSwitch]="true"
    [showStatus]="false"
  >
  </app-table>
</div>'

echo "$list_html_content" > "$list_component_html"

# Inform the user that the list component HTML file has been updated
echo "Updated $list_component_html with the specified content."

# Path to the list component TS file
list_component_ts="$module_name/pages/list-"$module_name"/list-"$module_name".component.ts"

# Generate the table columns based on the attributes
table_columns=""
for attribute in "${attributes[@]}"; do
  table_columns+="
    {
      name: '$(echo "$attribute" | tr '[:lower:]' '[:upper:]')',
      key: '$attribute',
    },"
done

# Content to be inserted into the list component TS file
list_ts_content="import {Component, inject, ViewChild} from '@angular/core';
import {SubscriptionContainer} from '../../../../../utils/SubscriptionContainer.util';
import {${module_name^}Service} from '../../services/${module_name}.service';
import {BehaviorSubject} from 'rxjs';
import {ActionButton, TableColumnGn, TableComponent} from '../../../../../common/table/table.component';
import {${module_name^}Model} from '../../models/${module_name}.model';
import {RestaurantService} from '../../../services/restaurant.service';

@Component({
  selector: 'app-liste-${module_name}',
  templateUrl: './list.component.html',
  styleUrls: ['./list.component.less']
})
export class List${module_name^}Component {
  //? ${module_name^}Service
  ${module_name}Service = inject(${module_name^}Service);
  restaurantService = inject(RestaurantService);

  //? Subscription container
  subs = new SubscriptionContainer();
  //? roles data
  ${module_name}s$: BehaviorSubject<${module_name^}Model[]> = new BehaviorSubject<${module_name^}Model[]>([]);
  //? selected${module_name^}ModelToBeDeleted
  selected${module_name^}ModelToBeDeleted: ${module_name^}Model | null = null;
  //? columns to be displayed in the table
  @ViewChild(TableComponent) tableComponent!: TableComponent<any>;

  tableColumns: TableColumnGn<${module_name^}Model>[] = [${table_columns}
  ];
  //? actions to be displayed in the table
  actionsBtns: ActionButton[] = [
    {
      label: 'Edit',
      action: (model: ${module_name^}Model) => {
        this.edit(model);
      },
      template: \`
      <div>
      <img
      src=\"../../../../../assets/images/restaurant/edit.png\"
      alt=\"\"
      class=\"w-5 h-5\"
    /></div>
      \`,
      dontShow: ()=>false
    },
    {
      label: 'Delete',
      action: (model: ${module_name^}Model) => {
        this.setSelected${module_name^}ModelToBeDeleted(model);
      },
      template: \`
      <div>
        <img
        src=\"../../../../../assets/images/restaurant/delete.png\"
        alt=\"\"
        class=\"w-5 h-5\"
      />
    </div>
      \`,
      dontShow: ()=>false
    },
  ];

  openModalAdd${module_name^}Model: boolean = false;
  openModaldelete${module_name^}Model: boolean = false;

  // open edit modal
  openEditModal: boolean = false;
  // open delete modal

  //delete model
  delete${module_name^}ModelModal: boolean = false;

  toggleModalDelete${module_name^}Model(status: boolean) {
    this.openModaldelete${module_name^}Model = false;
  }

  toggleModalAdd${module_name^}Model() {
    this.openModalAdd${module_name^}Model = !this.openModalAdd${module_name^}Model;
  }

  toggleModalEdit${module_name^}Model(status: boolean) {
    this.openEditModal = status;
  }

  closeModaldelete${module_name^}ModelFn(): void {
    this.openModaldelete${module_name^}Model = false;
    this.selected${module_name^}ModelToBeDeleted = null;
  }

  openModaldelete${module_name^}ModelFn(): void {
    this.openModaldelete${module_name^}Model = true;
  }

  edit(model: ${module_name^}Model) {
    this.toggleModalEdit${module_name^}Model(true);
    this.${module_name}Service.setSelected${module_name^}Model(model);
  }

  setSelected${module_name^}ModelToBeDeleted(model: ${module_name^}Model) {
    this.${module_name}Service.setSelected${module_name^}Model(model)
    this.openModaldelete${module_name^}ModelFn();
  }

  openModalAdd${module_name^}ModelFn(): void {
    this.openModalAdd${module_name^}Model = true;
  }

  closeModalAdd${module_name^}ModelFn(): void {
    this.openModalAdd${module_name^}Model = false;
    this.get${module_name^}sAll()
  }

  get${module_name^}sAll() {
    this.subs.add = this.${module_name}Service.get${module_name^}sAll().subscribe({
      next: (response) => {
        this.${module_name}s$.next(response);
        this.tableComponent.finishLoading()
      },
      error: (error) => {
        console.error('Une erreur s\\'est produite :', error);
        this.tableComponent.finishLoading();
      },
    });
  }

  create${module_name^}(${module_name^}: ${module_name^}Model) {
    this.subs.add = this.${module_name}Service.create${module_name^}(${module_name^}).subscribe({
      next: (response) => {
        console.log('${module_name^}Model ajouté avec succès :', response);
      },
      error: (error) => {
        console.error('Une erreur s\\'est produite :', error);
      },
    });
  }

  delete${module_name^}(${module_name^}: ${module_name^}Model) {
    if (${module_name^}) {
      this.subs.add = this.${module_name}Service.delete${module_name^}(${module_name^}.id).subscribe({
        next: (response) => {
          console.log('${module_name^}Model supprimé avec succès :', response);
        },
        error: (error) => {
          console.error('Une erreur s\\'est produite :', error);
        },
      });
    }
  }

  deleteFunc(model: ${module_name^}Model): void {
    this.delete${module_name^}(model);
    this.closeModaldelete${module_name^}ModelFn();
  }

  ngOnInit() {
    this.get${module_name^}sAll();
  }

  toggleStatus(${module_name}: ${module_name^}Model): void {
    if (${module_name}) {
      this.subs.add = this.${module_name}Service.update${module_name^}Status(${module_name}).subscribe({
        next: (response) => {
          console.log('${module_name^}Model supprimé avec succès :', response);
        },
        error: (error) => {
          console.error('Une erreur s\\'est produite :', error);
        },
      });
    }
  }
}
"

# Insert the content into the list component TS file
echo "$list_ts_content" > "$list_component_ts"

# Inform the user that the list component TS file has been updated
echo "Updated $list_component_ts with the specified content."

# add component
add_component_html="$module_name/pages/add-"$module_name"/add-"$module_name".component.html"

# Capitalize the module name
module_name_cap=$(echo "$module_name" | sed 's/.*/\u&/')

# Content to be inserted into the add component HTML file
# Content to be inserted into the add component HTML file
# Content to be inserted into the add component HTML file
module_nameForm="${module_name}Form"
add_html_content="<div class=\"p-7\">
  <img
    src=\"../../../../../../assets/images/restaurant/add_icon_header.png\"
    alt=\"add icon\"
    class=\"w-16 h-16\"
  />
  <form [formGroup]=\"$module_nameForm\" (submit)=\"onSubmit()\">
    <div class=\"grid grid-cols-2 gap-x-3 gap-y-6\">
      <div class=\"col-span-full\">
        <h4 class=\"f-outfit text-2xl\">
          Ajoût d'un $module_name_cap
        </h4>
        <h5 class=\"f-outfit text-gray-500\">
          Veuillez remplir les informations
        </h5>
      </div>
"

# Add form fields for each attribute dynamically
for attribute in "${attributes[@]}"; do
  add_html_content+="      <div class=\"col-span-1\">
        <label class=\"f-outfit pl-1 text-gray-500\" for=\"$attribute\">
          ${attribute^}
        </label>
        <div class=\"mt-1\">
          <input
            type=\"text\"
            id=\"$attribute\"
            placeholder=\"${attribute^}\"
            formControlName=\"$attribute\"
            class=\"w-full pr-3 pl-3 py-2 text-gray-500 bg-transparent outline-none border-2 focus:border-primary rounded-lg\"
          />
        </div>
        <div
          *ngIf=\"$module_nameForm.get('$attribute')?.invalid && $module_nameForm.get('$attribute')?.touched\"
          class=\"text-red-500 f-outfit\"
        >
          {{ \"$module_name_cap.COMPLETE_PROFILE.${attribute^^}_REQUIRED\" | translate }}
        </div>
      </div>
"
done

# Close the HTML content
add_html_content+="    </div>
    <div class=\"flex justify-end mt-10\">
      <button
        (click)=\"closeForm()\"
        class=\"bg-white border border-gray-300 center text-center h-12 text-gray-500 px-8 py-3 mx-1 rounded-md f-outfit\"
      >
        Annuler
      </button>
      <button
        class=\"bg-primary center text-center h-12 items-center text-white px-8 py-3 mx-1 rounded-md f-outfit\"
        type=\"submit\"
        [disabled]=\"loading\"
        [appLoading]=\"loading\"
        [initialContent]=\"'$module_name_cap.COMPLETE_PROFILE.SAVE' | translate\"
      >
        {{ \"$module_name_cap.COMPLETE_PROFILE.SAVE\" | translate }}
      </button>
    </div>
  </form>
</div>"

# Write the content to the add component HTML file
echo "$add_html_content" > "$add_component_html"

# Inform the user that the add component HTML file has been updated
echo "Updated add component HTML for '$module_name'."

# Inform the user that the add component HTML file has been updated
echo "Updated $add_component_html with the specified content."

# Path to the add component TS file
add_component_ts="$module_name/pages/add-"$module_name"/add-"$module_name".component.ts"

# Content to be inserted into the add component TS file
# Content to be inserted into the add component TypeScript file
add_ts_content="import {Component, EventEmitter, Inject, inject, Output} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from \"@angular/forms\";
import {${module_name_cap}Service} from \"../../services/${module_name}.service\";
import {TuiAlertService} from \"@taiga-ui/core\";

@Component({
  selector: 'app-add-${module_name}',
  templateUrl: './add-${module_name}.component.html',
  styleUrls: ['./add-${module_name}.component.less']
})
export class Add${module_name_cap}Component {
  ${module_name}Form: FormGroup;
  loading = false;
  @Output() close = new EventEmitter<void>();
  ${module_name}Service = inject(${module_name_cap}Service);

  constructor(private fb: FormBuilder,
              @Inject(TuiAlertService) private readonly alerts: TuiAlertService
  ) {
    this.${module_name}Form = this.fb.group({
"

# Add form controls for each attribute dynamically
for attribute in "${attributes[@]}"; do
  if [[ "$attribute" == "name" || "$attribute" == "deliveryFee" || "$attribute" == "minTimeToDeliver" ]]; then
    add_ts_content+="      $attribute: ['', [Validators.required]],
"
  else
    add_ts_content+="      $attribute: [''],
"
  fi
done

# Close the form group initialization
add_ts_content+="    });
  }

  onSubmit() {
    if (this.${module_name}Form.valid) {
      this.loading = true;
      this.${module_name}Service.create${module_name_cap}(this.${module_name}Form.value).subscribe({
        next: () => {
          this.loading = false;
          this.alerts.open('${module_name_cap} ajouté avec succès', {
            status: 'success',
            autoClose: true,
          }).subscribe();
          this.closeForm();
        },
        error: (error) => {
          this.loading = false;
        }
      })
    } else {
      this.alerts.open('Veuillez remplir les champs obligatoires', {
        status: 'error',
        autoClose: true,
      }).subscribe();

      this.${module_name}Form.markAllAsTouched();
    }
  }

  closeForm() {
    this.close.emit();
  }
}
"

# Write the content to the add component TypeScript file
echo "$add_ts_content" > "$add_component_ts"


# Inform the user that the add component TypeScript file has been updated
echo "Updated $add_component_ts with the specified content."


# Path to the edit component HTML file
edit_component_html="$module_name/pages/edit-"$module_name"/edit-"$module_name".component.html"
# Content to be inserted into the edit component HTML file
edit_html_content="<div class=\"p-7\">
  <img
    src=\"../../../../../../assets/images/restaurant/add_icon_header.png\"
    alt=\"add icon\"
    class=\"w-16 h-16\"
  />
  <form [formGroup]=\"edit${module_name_cap}Form\" (submit)=\"onSubmit()\">
    <div class=\"grid grid-cols-2 gap-x-3 gap-y-6\">
      <div class=\"col-span-full\">
        <h4 class=\"f-outfit text-2xl\">
          Modification d'un $module_name_cap {{
          ${module_name}Service.selected${module_name_cap}Model$.value?.name
          }}
        </h4>
        <h5 class=\"f-outfit text-gray-500\">
          Veuillez remplir les informations
        </h5>
      </div>
"

# Add form fields for each attribute dynamically
for attribute in "${attributes[@]}"; do
  edit_html_content+="      <div class=\"col-span-1\">
        <label class=\"f-outfit pl-1 text-gray-500\" for=\"$attribute\">
          ${attribute^}
        </label>
        <div class=\"mt-1\">
          <input
            type=\"text\"
            id=\"$attribute\"
            placeholder=\"${attribute^}\"
            formControlName=\"$attribute\"
            class=\"w-full pr-3 pl-3 py-2 text-gray-500 bg-transparent outline-none border-2 focus:border-primary rounded-lg\"
          />
        </div>
        <div
          *ngIf=\"edit${module_name_cap}Form.get('$attribute')?.invalid && edit${module_name_cap}Form.get('$attribute')?.touched\"
          class=\"text-red-500 f-outfit\"
        >
          {{ \"$module_name_cap.COMPLETE_PROFILE.${attribute^^}_REQUIRED\" | translate }}
        </div>
      </div>
"
done

# Close the HTML content
edit_html_content+="    </div>
    <div class=\"flex justify-end mt-10\">
      <button
        (click)=\"closeForm()\"
        class=\"bg-white border border-gray-300 center text-center h-12 text-gray-500 px-8 py-3 mx-1 rounded-md f-outfit\"
      >
        Annuler
      </button>
      <button
        class=\"bg-primary center text-center h-12 items-center text-white px-8 py-3 mx-1 rounded-md f-outfit\"
        type=\"submit\"
        [disabled]=\"edit${module_name_cap}Form.invalid\"
        [appLoading]=\"loading\"
        [initialContent]=\"'$module_name_cap.COMPLETE_PROFILE.SAVE' | translate\"
      >
        {{ \"$module_name_cap.COMPLETE_PROFILE.SAVE\" | translate }}
      </button>
    </div>
  </form>
</div>"

# Write the content to the edit component HTML file
echo "$edit_html_content" > "$edit_component_html"

# Inform the user that the edit component HTML file has been updated
echo "Updated edit component HTML for '$module_name'."

# Path to the edit component TS file
edit_component_ts="$module_name/pages/edit-"$module_name"/edit-"$module_name".component.ts"
# Content to be inserted into the edit component TypeScript file
edit_ts_content="import {Component, EventEmitter, Inject, inject, OnInit, Output} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from \"@angular/forms\";
import {${module_name_cap}Service} from \"../../services/${module_name}.service\";
import {TuiAlertService} from \"@taiga-ui/core\";
import {Subscription} from 'rxjs';

@Component({
  selector: 'app-edit-${module_name}',
  templateUrl: './edit-${module_name}.component.html',
  styleUrls: ['./edit-${module_name}.component.less']
})
export class Edit${module_name_cap}Component implements OnInit {
  edit${module_name_cap}Form: FormGroup;
  loading = false;
  @Output() close = new EventEmitter<void>();
  ${module_name}Service = inject(${module_name_cap}Service);
  private subscription: Subscription = new Subscription();

  constructor(private fb: FormBuilder,
              @Inject(TuiAlertService) private readonly alerts: TuiAlertService
  ) {
    this.edit${module_name_cap}Form = this.fb.group({
"

# Add form controls for each attribute dynamically
for attribute in "${attributes[@]}"; do
  if [[ "$attribute" == "name" || "$attribute" == "deliveryFee" || "$attribute" == "minTimeToDeliver" ]]; then
    edit_ts_content+="      $attribute: ['', [Validators.required]],
"
  else
    edit_ts_content+="      $attribute: [''],
"
  fi
done

# Close the form group initialization
edit_ts_content+="    });
  }

  ngOnInit() {
    this.subscription.add(
      this.${module_name}Service.selected${module_name_cap}Model$.subscribe(selected${module_name_cap} => {
        if (selected${module_name_cap}) {
          this.edit${module_name_cap}Form.patchValue(selected${module_name_cap});
        }
      })
    );
  }

  onSubmit() {
    if (this.edit${module_name_cap}Form.valid) {
      this.loading = true;
      this.${module_name}Service.update${module_name_cap}(this.edit${module_name_cap}Form.value).subscribe({
        next: () => {
          this.loading = false;
          this.alerts.open('${module_name_cap} modifié avec succès', {
            status: 'success',
            autoClose: true,
          }).subscribe();
          this.closeForm();
        },
        error: (error) => {
          this.loading = false;
        }
      })
    } else {
      this.alerts.open('Veuillez remplir les champs obligatoires', {
        status: 'error',
        autoClose: true,
      }).subscribe();

      this.edit${module_name_cap}Form.markAllAsTouched();
    }
  }

  closeForm() {
    this.close.emit();
  }

  ngOnDestroy() {
    this.subscription.unsubscribe();
  }
}
"

# Write the content to the edit component TypeScript file
echo "$edit_ts_content" > "$edit_component_ts"

# Inform the user that the edit component TypeScript file has been updated
echo "Updated edit component TypeScript for '$module_name'."

# service file
# Path to the service file
service_file="$module_name/services/$module_name.service.ts"


# Content to be inserted into the service file
# shellcheck disable=SC1068
service_content="import { inject, Injectable } from '@angular/core';
import { environment } from 'src/environment/environment';
import { BehaviorSubject, Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { ${module_name^}Model } from '../models/${module_name}.model';

@Injectable({
  providedIn: 'root',
})
export class ${module_name^}Service {
  api = environment.apiUrl + '/${module_name}';
  http = inject(HttpClient);

  selected${module_name^}Model$ = new BehaviorSubject<${module_name^}Model | null>(null);

  setSelected${module_name^}Model(${module_name}: ${module_name^}Model | null) {
    this.selected${module_name^}Model$.next(${module_name});
  }

  get${module_name^}sAll(page?: number, limit?: number): Observable<${module_name^}Model[]> {
    return this.http.get<${module_name^}Model[]>(\`\${this.api}\`);
  }

  create${module_name^}(${module_name}: ${module_name^}Model): Observable<${module_name^}Model> {
    return this.http.post<${module_name^}Model>(\`\${this.api}\`, ${module_name});
  }

  update${module_name^}(${module_name}: ${module_name^}Model): Observable<${module_name^}Model> {
    return this.http.put<${module_name^}Model>(\`\${this.api}/\${${module_name}.id}\`, ${module_name});
  }

  delete${module_name^}(id: number | undefined): Observable<${module_name^}Model> {
    return this.http.delete<${module_name^}Model>(\`\${this.api}/\${id}\`);
  }

  update${module_name^}Status(updated${module_name^}: ${module_name^}Model): Observable<${module_name^}Model> {
    return this.http.put<${module_name^}Model>(\`\${this.api}/\${updated${module_name^}.id}\`, updated${module_name^});
  }
}
"



# Insert the content into the service file
echo "$service_content" > "$service_file"

# Inform the user that the service file has been updated
echo "Updated $service_file with the specified content."


# Path to the module file
module_file="$module_name/$module_name.module.ts"

# Path to the routing module file
routing_module_file="$module_name/$module_name-routing.module.ts"

# Check if the module file exists
if [ -f "$module_file" ]; then
  # Inject the routing module into the main module
  sed -i "/@NgModule({/a \ \ imports: [\n \ \ \ \ CommonModule,
                                                      SharedComponentModule,
                                                      PartialUiModule,
                                                      TuiInputDateRangeModule,
                                                      NgxTranslationModule,
                                                      SharedModule \ \ ]," "$module_file"
  echo "Updated $module_file to include $module_name-routing.module"
else
  echo "Error: $module_file not found."
  exit 1
fi
