--本色史莱姆-治愈的颜色
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.AddXyzProcedureLevelFree(c,s.matfilter,nil,2,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_CANNOT_REMOVE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+10000)
	e3:SetTarget(s.desreptg)
	e3:SetValue(s.desrepval)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
	
end
function s.matfilter(c,xyzc)
	return (c:IsXyzLevel(xyzc,3) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_WATER)) or (c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP) and c:IsLocation(LOCATION_SZONE))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thfilter(c)
	return c:IsSetCard(0x579) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local hf=eg:Filter(s.repfilter,nil):GetSum(Card.GetAttack)
	e:SetLabel(hf)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96) 
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	local hf=e:GetLabel()
	Duel.Recover(tp,hf,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
end
function s.AddXyzProcedureLevelFree(c,f,gf,minc,maxc,alterf,alterdesc,alterop)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1165)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.XyzLevelFreeCondition(f,gf,minc,maxc,alterf,alterdesc,alterop))
	e1:SetTarget(s.XyzLevelFreeTarget(f,gf,minc,maxc,alterf,alterdesc,alterop))
	e1:SetOperation(s.XyzLevelFreeOperation(f,gf,minc,maxc,alterf,alterdesc,alterop))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
end
function s.XyzLevelFreeFilter(c,xyzc,f)
	return (not c:IsOnField() or c:IsFaceup()) and c:IsCanBeXyzMaterial(xyzc) and (not f or f(c,xyzc))
end
function Auxiliary.XyzLevelFreeGoal(g,tp,xyzc,gf)
	if Duel.GetLocationCountFromEx(tp,tp,g,xyzc)<=0 then return false end
	if gf and not gf(g,xyzc,tp) then return false end
	local lg=g:Filter(Card.IsHasEffect,nil,EFFECT_XYZ_MIN_COUNT)
	for c in Auxiliary.Next(lg) do
		local le=c:IsHasEffect(EFFECT_XYZ_MIN_COUNT)
		local ct=le:GetValue()
		if #g<ct then return false end
	end
	return true
end
function s.XyzLevelFreeCondition(f,gf,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,c,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				if maxc<minc then return false end
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0)
				end
				if alterf and (not min or min<=1) then
					if mg:IsExists(Auxiliary.XyzAlterFilter,1,nil,alterf,c,e,tp,alterop) then
						return true
					end
				end
				mg=mg:Filter(Auxiliary.XyzLevelFreeFilter,nil,c,f)
				local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
				if sg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(sg)
				Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
				local res=mg:CheckSubGroup(Auxiliary.XyzLevelFreeGoal,minc,maxc,tp,c,gf)
				Auxiliary.GCheckAdditional=nil
				return res
			end
end
function s.XyzLevelFreeTarget(f,gf,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
				if og and not min then
					return true
				end
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
				end
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0)
				end
				local b1=true
				local b2=false
				local altg=nil
				local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
				if alterf and (not min or min<=1) then
					altg=mg:Filter(Auxiliary.XyzAlterFilter,nil,alterf,c,e,tp,alterop)
					mg=mg:Filter(Auxiliary.XyzLevelFreeFilter,nil,c,f)
					Duel.SetSelectedCard(sg)
					Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
					b1=mg:CheckSubGroup(Auxiliary.XyzLevelFreeGoal,minc,maxc,tp,c,gf)
					Auxiliary.GCheckAdditional=nil
					b2=#altg>0
				else
					mg=mg:Filter(Auxiliary.XyzLevelFreeFilter,nil,c,f)
				end
				local g=nil
				local cancel=Duel.IsSummonCancelable()
				if b2 and (not b1 or Duel.SelectYesNo(tp,alterdesc)) then
					e:SetLabel(1)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local tc=altg:SelectUnselect(nil,tp,false,cancel,1,1)
					if tc then
						g=Group.FromCards(tc)
						if alterop then alterop(e,tp,1,tc) end
					end
				else
					e:SetLabel(0)
					Duel.SetSelectedCard(sg)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					Auxiliary.GCheckAdditional=Auxiliary.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
					g=mg:SelectSubGroup(tp,Auxiliary.XyzLevelFreeGoal,cancel,minc,maxc,tp,c,gf)
					Auxiliary.GCheckAdditional=nil
				end
				if g and g:GetCount()>0 then
					g:KeepAlive()
					e:SetLabelObject(g)
					return true
				else return false end
			end
end
function s.XyzLevelFreeOperation(f,gf,minct,maxct,alterf,alterdesc,alterop)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
				if og and not min then
					local sg=Group.CreateGroup()
					local tc=og:GetFirst()
					while tc do
						local sg1=tc:GetOverlayGroup()
						sg:Merge(sg1)
						tc=og:GetNext()
					end
					Duel.SendtoGrave(sg,REASON_RULE)
					c:SetMaterial(og)
					Duel.Overlay(c,og)
				else
					local mg=e:GetLabelObject()
					if e:GetLabel()==1 then
						local mg2=mg:GetFirst():GetOverlayGroup()
						if mg2:GetCount()~=0 then
							Duel.Overlay(c,mg2)
						end
					else
						local sg=Group.CreateGroup()
						local tc=mg:GetFirst()
						while tc do
							local sg1=tc:GetOverlayGroup()
							sg:Merge(sg1)
							tc=mg:GetNext()
						end
						Duel.SendtoGrave(sg,REASON_RULE)
					end
					c:SetMaterial(mg)
					Duel.Overlay(c,mg)
					mg:DeleteGroup()
				end
			end
end
