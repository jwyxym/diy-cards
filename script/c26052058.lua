local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1164)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.syncon)
	e0:SetTarget(s.syntg)
	e0:SetOperation(s.synop)
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e0)
	local e01=Effect.CreateEffect(c)
	e01:SetType(EFFECT_TYPE_FIELD)
	e01:SetCode(EFFECT_SYNCHRO_LEVEL_EX)
	e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e01:SetRange(LOCATION_EXTRA)
	e01:SetTargetRange(LOCATION_MZONE,0)
	e01:SetTarget(s.exleveltg)
	e01:SetValue(s.exlevel)
	c:RegisterEffect(e01)
	local e02=Effect.CreateEffect(c)
	e02:SetType(EFFECT_TYPE_SINGLE)
	e02:SetCode(EFFECT_SPSUMMON_CONDITION)
	e02:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e02:SetValue(aux.synlimit)
	c:RegisterEffect(e02)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.exfilter(c)
	return c:IsSetCard(0x902) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function s.exleveltg(e,c)
	return s.exfilter(c)
end
function s.exlevel(e,sc)
	if sc==e:GetHandler() then return 1 end
	return 0
end
function s.ntfilter(c,sc)
	return c:IsCode(26051905)
end
function s.tfilter(c,sc)
	return c:IsSetCard(0x902) and (c:IsTuner(sc) or s.exfilter(c))
end
function s.matlevel(c,sc)
	local lv=c:GetSynchroLevel(sc)
	if not s.exfilter(c) then return lv end
	if c:IsTuner(sc) then return lv|0x10000 end
	return 1
end
function s.matcheck(g,sc,smat,min,max)
	local ct=g:GetCount()
	if (min and ct<min) or (max and ct>max) then return false end
	if smat and not g:IsContains(smat) then return false end
	local ng=g:Filter(s.ntfilter,nil,sc)
	if ng:GetCount()~=1 then return false end
	local nt=ng:GetFirst()
	if g:FilterCount(s.tfilter,nt,sc)~=ct-1 then return false end
	local tp=sc:GetControler()
	if Duel.GetLocationCountFromEx(tp,tp,g,sc)<=0
		or not aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
		or not aux.SynMixHandCheck(g,tp,sc) then return false end
	if not g:CheckWithSumEqual(s.matlevel,sc:GetLevel(),ct,ct,sc) then return false end
	for tc in aux.Next(g) do
		local le,lf,lloc,lmin,lmax=tc:GetTunerLimit()
		if le then
			local lct=ct-1
			if lloc and g:FilterCount(Card.IsLocation,tc,lloc)~=lct then return false end
			if lf and g:IsExists(aux.SynLimitFilter,1,tc,lf,le,sc) then return false end
			if (lmin and lct<lmin) or (lmax and lct>lmax) then return false end
		end
	end
	return true
end
function s.synmaterials(sc,smat,mg)
	local g
	if mg then g=mg:Filter(Card.IsCanBeSynchroMaterial,nil,sc)
	else g=aux.GetSynMaterials(sc:GetControler(),sc) end
	if smat then g:AddCard(smat) end
	return g
end
function s.syncon(e,c,smat,mg,min,max)
	if c==nil then return true end
	local g=s.synmaterials(c,smat,mg)
	return g:CheckSubGroup(s.matcheck,4,63,c,smat,min,max)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk,sc,smat,mg,min,max)
	local g=s.synmaterials(sc,smat,mg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local sg=g:SelectSubGroup(tp,s.matcheck,true,4,63,sc,smat,min,max)
	if not sg then return false end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,sc)
	local g=e:GetLabelObject()
	sc:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	g:DeleteGroup()
end
function s.regcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.regop(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local ct=Duel.GetTurnPlayer()==tp and 1 or 2
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetLabel(Duel.GetTurnCount()+ct)
	e4:SetCondition(s.delaycon)
	e4:SetTarget(s.delaysptg)
	e4:SetOperation(s.delayspop)
	e4:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ct)
	Duel.RegisterEffect(e4,tp)
end
function s.sumlimit(e,c)
	return not c:IsSetCard(0x902)
end
function s.delaycon(e,tp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()==e:GetLabel()
end
function s.spfilter(c,e,tp)
	return c:IsCode(26052059) and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.delaysptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.delayspop(e,tp)
	e:Reset()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP) end
end
function s.tdcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and (not c:IsLocation(LOCATION_EXTRA)
		or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,
		LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.tdop(e,tp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,
		LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,e:GetHandler())
	if aux.NecroValleyNegateCheck(g) then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
