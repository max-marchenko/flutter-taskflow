create extension if not exists "pgcrypto";

create type workspace_role as enum ('owner', 'admin', 'member', 'viewer');
create type project_status as enum ('planned', 'active', 'paused', 'completed', 'archived');
create type task_status as enum ('backlog', 'todo', 'in_progress', 'review', 'done', 'archived');
create type task_priority as enum ('low', 'medium', 'high', 'urgent');
create type activity_event_type as enum ('task_created', 'task_updated', 'comment_added', 'status_changed', 'assignee_changed', 'project_created');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null unique,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  created_by uuid not null references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table workspace_members (
  workspace_id uuid not null references workspaces(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  role workspace_role not null default 'member',
  title text not null default '',
  joined_at timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

create table projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces(id) on delete cascade,
  name text not null,
  description text not null default '',
  status project_status not null default 'planned',
  owner_id uuid references profiles(id),
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces(id) on delete cascade,
  project_id uuid not null references projects(id) on delete cascade,
  title text not null,
  description text not null default '',
  status task_status not null default 'todo',
  priority task_priority not null default 'medium',
  assignee_id uuid references profiles(id),
  due_date date,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table labels (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces(id) on delete cascade,
  name text not null,
  color text not null,
  unique (workspace_id, name)
);

create table task_labels (
  task_id uuid not null references tasks(id) on delete cascade,
  label_id uuid not null references labels(id) on delete cascade,
  primary key (task_id, label_id)
);

create table task_comments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references tasks(id) on delete cascade,
  author_id uuid not null references profiles(id),
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table activity_events (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references workspaces(id) on delete cascade,
  project_id uuid references projects(id) on delete cascade,
  task_id uuid references tasks(id) on delete cascade,
  actor_id uuid references profiles(id),
  type activity_event_type not null,
  message text not null,
  created_at timestamptz not null default now()
);

create index idx_workspace_members_user on workspace_members(user_id);
create index idx_projects_workspace on projects(workspace_id);
create index idx_tasks_project_status on tasks(project_id, status);
create index idx_tasks_assignee_due on tasks(assignee_id, due_date);
create index idx_activity_workspace_created on activity_events(workspace_id, created_at desc);

alter table profiles enable row level security;
alter table workspaces enable row level security;
alter table workspace_members enable row level security;
alter table projects enable row level security;
alter table tasks enable row level security;
alter table labels enable row level security;
alter table task_labels enable row level security;
alter table task_comments enable row level security;
alter table activity_events enable row level security;

-- RLS intent:
-- Reads require membership in the workspace.
-- Owners have full workspace access and owner-only destructive controls.
-- Admins manage projects, tasks, labels, comments, and non-owner members.
-- Members create/comment/update assigned tasks.
-- Viewers are read-only.
-- Add helper functions such as is_workspace_member() and role checks before production deployment.
