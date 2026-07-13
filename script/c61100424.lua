--本色史莱姆-汇集的颜色
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.AddXyzProcedureLevelFree(c,s.matfilter,nil,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(function(e,c) return c:GetOverlayCount()*500 end)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.ovltg)
	e2:SetOperation(s.ovlop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.rscon)
	e3:SetCost(s.mthcost)
	e3:SetTarget(s.mthtg)
	e3:SetOperation(s.mthop)
	c:RegisterEffect(e3)

	
end
function s.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.matfilter(c,xyzc)
	return (c:IsXyzLevel(xyzc,3) and c:IsLocation(LOCATION_MZONE)) or (c:IsXyzType(TYPE_MONSTER) and c:IsType(TYPE_EQUIP) and c:IsLocation(LOCATION_SZONE))
end
function s.matfilter2(c,hc,e)
	local seq=c:GetSequence()
	return c~=hc and c:IsCanBeXyzMaterial(hc) and seq<5
		and math.abs(hc:GetSequence()-seq)<=1
end

function s.matfilter3(c,hc,e,cg,tp)
	local seq=hc:GetSequence()
	if seq<5 then
		return c~=hc and c:IsCanOverlay() and cg:IsContains(c) and (c:IsControler(tp) or c:GetSequence()>4)
	end
	if seq>4 then
		return c~=hc and c:IsCanOverlay() and cg:IsContains(c) and c:IsLocation(LOCATION_MZONE)
	end
	return false
end

function s.ovltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hc=e:GetHandler()
	local cg=hc:GetColumnGroup()
	local g=Duel.GetMatchingGroup(s.matfilter2,tp,LOCATION_MZONE,0,nil,hc,e)
	local ng=Duel.GetMatchingGroup(s.matfilter3,tp,LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE,nil,hc,e,cg,tp)
	g:Merge(ng)
	if chk==0 then return #g>0 end
end

function s.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetHandler()
	local cg=hc:GetColumnGroup()
	if not hc:IsRelateToEffect(e) or hc:IsImmuneToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.matfilter2,tp,LOCATION_MZONE,0,nil,hc,e)
	local ng=Duel.GetMatchingGroup(s.matfilter3,tp,LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE,nil,hc,e,cg,tp)
	g:Merge(ng)
	if #g>0 then
		for tc in aux.Next(g) do
			local og=tc:GetOverlayGroup()
			if #og>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
		Duel.Overlay(hc,g)
	end
end
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end

function s.mthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

function s.mthfilter(c)
	return c:IsSetCard(0x579) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.mthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mthfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.mthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mthfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc or Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
	if tc:IsType(TYPE_FIELD) then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then Duel.SendtoGrave(fc,REASON_RULE) end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	elseif tc:IsType(TYPE_CONTINUOUS) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	elseif tc:IsType(TYPE_QUICKPLAY) or tc:IsType(TYPE_TRAP) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		end
	end
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
