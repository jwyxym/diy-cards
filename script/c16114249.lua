--冒险仙精 珀蕾可
xpcall(function() dofile("expansions/script/c16199990.lua") end,function() dofile("script/c16199990.lua") end)
local m,cm=rk.set(16114249)
function cm.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1166)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.lcon)
	e1:SetTarget(cm.ltg)
	e1:SetOperation(Auxiliary.LinkOperation(nil,2,4,cm.gf))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1) 
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(cm.atktg)
	e2:SetOperation(cm.atkop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.seacon)
	e3:SetTarget(cm.seatg)
	e3:SetOperation(cm.seaop)
	c:RegisterEffect(e3)
end
--linkfilter
function cm.gf(g)
	return g:FilterCount(function(c) return not c:IsSetCard(0xccf) end,nil)<=1
end
function cm.lcon(...)
	local f=aux.GetLinkMaterials
	aux.GetLinkMaterials=cm.GetLinkMaterials
	local res=Auxiliary.LinkCondition(nil,2,4,cm.gf)(...)
	aux.GetLinkMaterials=f
	return res
end
function cm.ltg(...)
	local f=aux.GetLinkMaterials
	aux.GetLinkMaterials=cm.GetLinkMaterials
	local res=Auxiliary.LinkTarget(nil,2,4,cm.gf)(...)
	aux.GetLinkMaterials=f
	return res
end
function cm.Linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xccf)
end
function cm.Linkfilter2(c,lc)
	return c:IsFaceup()  and c:IsCanBeLinkMaterial(lc)
end
function cm.GetLinkMaterials(tp,f,lc,e)
	local mg=Duel.GetMatchingGroup(Auxiliary.LConditionFilter,tp,LOCATION_MZONE,0,nil,cm.Linkfilter,lc,e)
	local mg2=Duel.GetMatchingGroup(Auxiliary.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,cm.Linkfilter,lc,tp,e)
	local mg3=Duel.GetMatchingGroup(cm.Linkfilter2,tp,0,LOCATION_MZONE,nil,lc,e)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	if mg3:GetCount()>0 then mg:Merge(mg3) end
	return mg
end
--e2
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
--e3
function cm.seacon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsSetCard(0xccf)
end
function cm.seatgf(c,rc)
	return c:IsSetCard(0xccf) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
function cm.seatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.seatgf,tp,LOCATION_DECK,0,1,nil,re:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.seaop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.seatgf,tp,LOCATION_DECK,0,nil,re:GetHandler())
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end