--黄金拼图 小路绫
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_LEAVE_GRAVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.tdcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(cm.recon)
	e2:SetTarget(cm.retg)
	e2:SetOperation(cm.reop)
	c:RegisterEffect(e2)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND) and not g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsType(TYPE_LINK)
end

function cm.tgtfilter(c,e,tp,zone)
    return c:IsLink(2) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgtfilter,tp,0x20,0x20,1,nil,e,tp,zone) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x20)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.tgtfilter,tp,0x20,0x20,1,1,nil,e,tp,zone)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
    end
end

function cm.recon(e,tp,eg,ep,ev,re,r,rp)
    local ec=eg:GetFirst()
	return #eg==1 and ec:IsLink(2) and e:GetHandler():GetLinkedGroup():IsContains(ec) and not ec:IsCode(m)
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ea=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_DAMAGE)
	local eb=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_RECOVER)
	if chk==0 then return eg:GetFirst():IsAbleToGrave() and Duel.GetLP(tp)<8000 and (ea or not eb) end
    Duel.SetTargetCard(eg)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eg:GetFirst(),1,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,8000-Duel.GetLP(tp))
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT) then
		local lp=Duel.GetLP(tp)
        if lp<8000 then
			Duel.Recover(tp,8000-lp,REASON_EFFECT)
		end
    end
end