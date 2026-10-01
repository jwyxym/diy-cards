--圣浊的统帅·天使长
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--召唤规则
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(s.settcon)
	c:RegisterEffect(e2)
	--双召限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	local e3=e0:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e3)
	--卡组检索
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--特殊召唤    
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id+o*1000)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--攻守上升
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.atktg)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)    
end
function s.ttfilter(c)
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsReleasable(REASON_SUMMON|REASON_MATERIAL)
end
function s.exttfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.httgcheck(g)
	if g:GetSum(Card.GetLevel)<=7 then return true end
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,7)
end
function s.httcheck(g,tp)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,7) and Duel.GetMZoneCount(tp,g)>0
end
function s.ttcon(e,c,minc)
	if c==nil then return true end
    local tp=c:GetControler()
    local mg1=Duel.GetMatchingGroup(s.ttfilter,tp,LOCATION_MZONE,0,nil)
    local mg2=Duel.GetMatchingGroup(s.exttfilter,tp,LOCATION_EXTRA,0,nil)
    mg1:Merge(mg2)
	aux.GCheckAdditional=s.httgcheck
	local res=mg1:CheckSubGroup(s.httcheck,1,mg1:GetCount(),tp)
	aux.GCheckAdditional=nil
	return res
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(s.ttfilter,tp,LOCATION_MZONE,0,nil)
    local mg2=Duel.GetMatchingGroup(s.exttfilter,tp,LOCATION_EXTRA,0,nil)
    mg1:Merge(mg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	aux.GCheckAdditional=s.httgcheck
	local sg=mg1:SelectSubGroup(tp,s.httcheck,false,1,mg1:GetCount(),tp)
	aux.GCheckAdditional=nil	
	c:SetMaterial(sg)
    local zg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
    local exg=sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
    if zg:GetCount()>0 then
		Duel.Release(zg,REASON_SUMMON+REASON_MATERIAL)
    end
    if exg:GetCount()>0 then
    	Duel.SendtoGrave(exg,REASON_SUMMON+REASON_MATERIAL)
    end
end
function s.settcon(e,c,minc)
	if not c then return true end
	return false
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x6ce1)
end
function s.confilter(c)
	return c:IsSetCard(0x6ce1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function s.thfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
        local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_PZONE,0,nil)
        if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        	Duel.BreakEffect()
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=dg:Select(tp,1,1,nil)
            if sg:GetCount()>0 then
            	Duel.HintSelection(sg)
            	Duel.Destroy(sg,REASON_EFFECT)
            end
        end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x6ce1) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsFaceup())
        	or (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
    	and c:GetMaterial():GetSum(Card.GetLevel)==7 and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.atktg(e,c)
	return c:IsSetCard(0x6ce1)
end
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)*500
end