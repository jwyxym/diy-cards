--血红的妖精公主 芭万·希
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddLinkProcedure(c,nil,3,99,this.lcheck)
	c:EnableReviveLimit()
    aux.AddCodeList(c,72600200)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.scon)
    e1:SetTarget(this.stg)
    e1:SetOperation(this.sop)
    c:RegisterEffect(e1)
    aux.EnableChangeCode(c,72600200,LOCATION_MZONE+LOCATION_GRAVE)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+1)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCost(this.descost)
	e1:SetTarget(this.destg)
	e1:SetOperation(this.desop)
	c:RegisterEffect(e1)
end
function this.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TOKEN) and g:IsExists(Card.IsLinkCode,1,nil,72600200)
end
function this.sfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and aux.IsCodeListed(c,72600200)
end
function this.gcheck(g)
    if g:FilterCount(Card.IsType,nil,TYPE_FIELD)>1 then return false end
    return true
end
function this.gselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft and aux.dncheck(g)
end
function this.scon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function this.stg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lg=e:GetHandler():GetMaterial()
    local ct=0
    for tc in aux.Next(lg) do
        if tc:IsType(TYPE_TOKEN) then ct=ct+1 end
    end
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(this.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function this.sop(e,tp,eg,ep,ev,re,r,rp)
    local lg=e:GetHandler():GetMaterial()
    local ct=0
    for tc in aux.Next(lg) do
        if tc:IsType(TYPE_TOKEN) then ct=ct+1 end
    end
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(this.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #g==0 or ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tg=g:SelectSubGroup(tp,this.gselect,false,1,math.min(ct,ft+1),ft)
	if Duel.SSet(tp,tg)==0 then return end
	local tc=tg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end
function this.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_TOKEN) and Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE,0,1,1,nil,TYPE_TOKEN)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
		Duel.HintSelection(g1)
		Duel.Destroy(g1,REASON_EFFECT)
	end
end
