--算子械模块-Windows.A
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.cost)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.cost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if not re:GetHandler():IsCode(id) then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(e:GetHandler())
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se:GetHandler() and c:IsLocation(LOCATION_EXTRA)
		and not c:IsSetCard(0x404)
end
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevelAbove(1) and c:IsType(TYPE_NORMAL)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and not c:IsHasEffect(id,tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp,c:GetLevel())
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfilter(c,tp,lv)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
		and (c:IsLevel(lv-1) or c:IsLevel(lv+1))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=eg:Filter(s.cfilter,nil,tp)
	if chk==0 then return g1:GetCount()>0 end
	g1:KeepAlive()
	e:SetLabelObject(g1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=e:GetLabelObject()
	local g2=g1:Filter(s.cfilter,nil,tp)
	if g2:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g3=g2:Select(tp,1,1,nil)
	local gc=g3:GetFirst()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(id)
	e0:SetTargetRange(LOCATION_GRAVE+LOCATION_REMOVED,0)
	e0:SetTarget(s.thlimit)
	e0:SetLabel(gc:GetLevel())
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	local lv=gc:GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,lv)
	local tc=sg:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.thlimit(e,c,tp,re)
	return c:IsLevel(e:GetLabel())
end
function s.costfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsType(TYPE_NORMAL)
end
function s.gcheck(g,e,tp)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv=0
	if tc1:GetLevel()==tc2:GetLevel() then return false end
	if tc1:GetLevel()>tc2:GetLevel() then
		lv=tc1:GetLevel()-tc2:GetLevel()
	else
		lv=tc2:GetLevel()-tc1:GetLevel()
	end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g,lv)
end
function s.spfilter(c,e,tp,g,lv)
	local check=false
	if c:IsLocation(LOCATION_DECK) then
		check=Duel.GetMZoneCount(tp,g)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		check=Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	end
	return check and c:IsType(TYPE_SYNCHRO)
		and (c:IsLevel(lv) or s.sumf(c,lv))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sumf(c,lv)
	if not c.sunss then return false end
	local res=false
	for key,value in ipairs(c.sunss) do
		if res==false and lv==value then
			res=true
		end
	end
	return res
end
function s.lvgg(g)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local lv=0
	if tc1:GetLevel()>tc2:GetLevel() then
		lv=tc1:GetLevel()-tc2:GetLevel()
	else
		lv=tc2:GetLevel()-tc1:GetLevel()
	end
	return lv
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.costfilter,nil,tp)
	if chk==0 then return e:IsCostChecked()
		and g:CheckSubGroup(s.gcheck,2,2,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,e,tp)
	local lv=s.lvgg(sg)
	Duel.Release(sg,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,lv)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end