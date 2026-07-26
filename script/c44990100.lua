--伊瑟拉
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	aux.AddXyzProcedure(c,s.xyzfilter,9,2)
	c:EnableReviveLimit()

	-- ① 无效魔法并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- ② 吸收魔法卡 + 选破
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.abscon)
	e2:SetTarget(s.abstg)
	e2:SetOperation(s.absop)
	c:RegisterEffect(e2)
end

function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevel(9) and c:IsFaceup()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

function s.IsYseraCard(c)
	return aux.IsCodeListed(c,id)
end

function s.abscon(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp) then return false end
	local rc=re:GetHandler()
	return rc and rc:IsType(TYPE_SPELL) and s.IsYseraCard(rc)
end

function s.abstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	re:GetHandler():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

function s.absop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		if Duel.Overlay(c,tc)~=0 then
			local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=g:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
		end
	end
end