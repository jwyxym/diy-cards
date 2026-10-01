--播种者 普莉玛
local s,id,o=GetID()
function s.initial_effect(c)
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
	--回到卡组    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--无效    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
function s.ttfilter(c)
	return c:IsLevelAbove(1) and c:IsType(TYPE_MONSTER) and c:IsReleasable(REASON_SUMMON|REASON_MATERIAL)
end
function s.exttfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.httgcheck(g)
	if g:GetSum(Card.GetLevel)<=11 then return true end
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,11)
end
function s.httcheck(g,tp)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,11) and Duel.GetMZoneCount(tp,g)>0
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
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))
    if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
    	and c:GetMaterial():GetSum(Card.GetLevel)==11 and c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)    
	end
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
	return c:IsSetCard(0x6ce1) and c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost()
end
function s.fselect(g)
	return g:GetSum(Card.GetLevel)==5 or g:GetSum(Card.GetLevel)==7
end
function s.gcheck(g)
	return g:GetSum(Card.GetLevel)<=5 or g:GetSum(Card.GetLevel)<=7
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
    aux.GCheckAdditional=s.gcheck
    if chk==0 then 
    	local res=g:CheckSubGroup(s.fselect,1,g:GetCount())
		aux.GCheckAdditional=nil
		return res
    end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:SelectSubGroup(tp,s.fselect,false,1,g:GetCount())
	aux.GCheckAdditional=nil
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end